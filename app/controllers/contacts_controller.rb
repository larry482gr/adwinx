require 'digest/sha1'
require 'thread'

class ContactsController < ApplicationController
  include ActionController::Live
  include ContactsHelper

  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :belonging_groups]

  # GET /contacts
  # GET /contacts.json
  def index
    params_hash = contact_params unless params[:contact].nil?

    pars = get_filter_params params_hash

    params[:page] ||= 1
    params[:limit] ||= Contact::DEFAULT_PER_PAGE
    params[:limit] = Contact::RESULTS_PER_PAGE.max unless params[:limit].to_i <= Contact::RESULTS_PER_PAGE.max

    contact_ids = Rails.cache.fetch("#{contacts_url}?q=#{Digest::SHA1.hexdigest(pars.inspect)}",
                                    :tag => ["contacts-filter-#{current_user.id}"]) do

      Contact.where('$and' => pars).pluck(:_id)
    end

    @contacts = Contact.includes(:contact_groups).where(:_id => { '$in' => contact_ids })
                    .asc('contact_profile.last_name').asc('contact_profile.first_name')
                    .page(params[:page]).per(params[:limit])

    if @contacts.size < (params[:page].to_i*params[:limit].to_i - params[:limit].to_i)
      params[:page] = @contacts.num_pages
      redirect_to host: contacts_url, params: params and return
    end

    @metadata = current_user.metadata
    @groups   = ContactGroup.where(uid: current_user.id).asc('label')
    @filters_form_action = '/contacts'

    respond_to do |format|
      format.html { render :index }
      format.json { render json: { metadata: @metadata, contacts: @contacts, groups: @groups } }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
    create_profile
  end

  # GET /contacts/1/edit
  def edit
    create_profile
  end

  # POST /contacts
  # POST /contacts.json
  def create
    pars = contact_params
    pars[:uid] = current_user.id

    group_ids = []
    unless pars[:contact_group_attributes].nil?
      pars[:contact_group_attributes].each do |group|
        group_ids << group[:_id]
      end
    end
    pars.delete(:contact_group_attributes)
    pars[:contact_group_ids] = group_ids

    @contact = Contact.new(pars)

    if group_ids.blank?
      @contact.unset(:contact_group_ids)
    else
      @contact.set(contact_group_ids: group_ids)
    end

    respond_to do |format|
      begin
        if @contact.save
          Cashier.expire "contacts-filter-#{current_user.id}"
          format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
          format.json { render :show, status: :created, location: @contact }
        else
          create_profile
          format.html { render :new }
          format.json { render json: @contact.errors, status: :unprocessable_entity }
        end
      rescue Mongo::Error::OperationFailure => exception
        debug_inspect exception
        @contact = duplicate_contact
        create_profile

        error = (t 'mongoid.errors.contact.duplicate_val').gsub('%phone%', "#{@contact.prefix} #{@contact.mobile}")
        @contact.errors[t 'mongoid.errors.contact.duplicate_key'] = error

        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    pars = contact_params
    pars[:uid] = current_user.id

    group_ids = []
    unless pars[:contact_group_attributes].nil?
      pars[:contact_group_attributes].each do |group|
        group_ids << BSON::ObjectId.from_string(group[:_id])
      end
    end
    pars.delete(:contact_group_attributes)

    if group_ids.blank?
      @contact.unset(:contact_group_ids)
    else
      @contact.set(contact_group_ids: group_ids)
    end

    respond_to do |format|
      begin
        if @contact.update(pars)
          expire_fragment contact_url(@contact)
          if pars[:contact_profile_attributes][:last_name] != @contact.contact_profile[:last_name] or
              pars[:contact_profile_attributes][:first_name] != @contact.contact_profile[:first_name]
            Cashier.expire "contacts-filter-#{current_user.id}"
          end

          format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
          format.json { render :show, status: :ok, location: @contact }
        else
          create_profile
          format.html { render :edit }
          format.json { render json: @contact.errors, status: :unprocessable_entity }
        end
      rescue Mongo::Error::OperationFailure => exception
        create_profile
        contact = duplicate_contact
        error = (t 'mongoid.errors.contact.duplicate_val')
                    .gsub('%phone%', "#{contact_params[:prefix]} #{contact_params[:mobile]}")
        @contact.errors[t 'mongoid.errors.contact.duplicate_key'] =
            "#{error} <a href=\"#{contact_path contact}\">#{t 'view_contact'}</a>"

        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    Cashier.expire "contacts-filter-#{current_user.id}"
    respond_to do |format|
      format.html { redirect_to contacts_url, notice: 'Contact was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /contacts/bulk_delete
  # POST /contacts/bulk_delete.json
  def bulk_delete
    contact_ids = []
    contact_params[:contact_ids].each do |cid|
      contact_ids << BSON::ObjectId.from_string(cid)
    end

    deleted = Contact.where(uid: current_user.id).in(:_id => contact_ids).delete_all

    Cashier.expire "contacts-filter-#{current_user.id}"
    respond_to do |format|
      format.js {}
      format.json { render json: { deleted: deleted } }
    end
  end

  # GET /contacts/1/belonging_groups
  # GET /contacts/1/belonging_groups.json
  def belonging_groups
    contact_groups = []
    @contact.contact_groups.each do |group|
      contact_groups << { _id: group['_id'].to_s, lbl: group['label'] }
    end

    respond_to do |format|
      format.js {}
      format.json { render json: contact_groups }
    end
  end

  # GET /contacts/csv_template
  def csv_template
    send_csv(get_contacts_template_data, 'csv_template')

  end

  # GET /contacts/xlsx_template
  def xlsx_template
    send_xlsx(get_contacts_template_data, 'xlsx_template')
  end

  # POST /contacts/bulk_import
  def bulk_import
    response.headers['Content-Type'] = 'text/event-stream'

    start_time = Time.now.to_f

    filetype = params[:contact][:contact_lists].content_type

    response.stream.write ({ rs: "Processing file..." }).to_json
    sleep 0.1

    contacts = parse_contacts filetype

    if contacts.is_a? Hash and contacts[:invalid] and not contacts[:labels].blank?
      response.stream.write ({ rs: "The file you are trying to import contains these invalid fields:<br/>
                                        #{contacts[:labels].join(', ')}<br/>
                                        Please check that they are defined in your <a href=\"/users/edit\">Profile Settings</a>.",
                               st: 450.to_s }).to_json
    elsif contacts.is_a? Hash and contacts[:missing] and not contacts[:labels].blank?
      response.stream.write ({ rs: "The file you are trying to import does not contain #{contacts[:labels].count} mandatory field(s):<br/>
                                        #{contacts[:labels].join(', ')}",
                               st: 451.to_s }).to_json
    else
      total_contacts = contacts.size
      response.stream.write ({ rs: "Creating contacts...", tc: total_contacts.to_s }).to_json
      sleep 0.1

      # import_result = import_contacts contacts

      import_result_1, import_result_2 = { inserted: 0, updated: 0 }



      @mutex = Mutex.new
      @command_queue = Queue.new
      @i = 0

      t1 = Thread.new{
        import_result_1 = import_contacts contacts.select.with_index { |_, i| i.even? }
      }

      t2 = Thread.new{
        import_result_2 = import_contacts contacts.select.with_index { |_, i| i.odd? }
      }

      while command = @command_queue.pop
        response.stream.write command.to_json
      end

      t1.join
      t2.join

      total_inserted  = import_result_1[:inserted] + import_result_2[:inserted]

      total_updated   = import_result_1[:updated] + import_result_2[:updated]

      end_time = Time.now.to_f

      sleep 0.1
      response.stream.write ({ pc: (total_inserted + total_updated).to_s,
                               pg: (((total_inserted + total_updated)/total_contacts)*100).to_s,
                               tc: total_contacts.to_s,
                               rs: "New: #{total_inserted.to_s} | Updated: #{total_updated.to_s}<br/>
                                        Execution time: #{(end_time-start_time).to_s}" }).to_json
      sleep 0.1
    end
  ensure
    Cashier.expire "contacts-filter-#{current_user.id}"
    response.stream.close
  end

  # GET /contacts/export_list
  def export_list
    contacts = Contact.where(uid: current_user.id, lists: "#{params[:filename]}.#{params[:format]}").asc(:_id)
    group_labels = {}

    contact_groups = ContactGroup.where(uid: current_user.id)
    contact_groups.each do |group|
      group_labels[group[:_id]] = group[:label]
    end

    metadata = current_user.metadata

    data = {}

    data[:headers] = %w(prefix mobile).concat(metadata).push('groups')
    data[:rows] = []

    contacts.each do |contact|
      row = []
      row << contact[:prefix]
      row << contact[:mobile]
      metadata.each do |field|
        if contact.contact_profile[field].blank?
          row << ' '
        else
          row << contact.contact_profile[field]
        end
      end
      groups = []
      contact.contact_groups.each do |group|
        groups << group_labels[group[:_id]]
      end
      row << groups.join('/')
      data[:rows] << row
    end

    respond_to do |format|
      format.csv { send_csv(data, params[:filename]) }
      format.xlsx { send_xlsx(data, params[:filename]) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      begin
        @contact = Contact.find_by(:_id => params[:id], :uid => current_user.id)
      rescue Mongoid::Errors::DocumentNotFound => e
        debug_inspect "Mongoid::Errors::DocumentNotFound: message: Document not found for class Contact with attributes {:_id=>\"#{params[:id]}\", :uid=>#{current_user.id}}."
        redirect_to :root, alert: 'No Access!' and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:prefix, :mobile, :contact_lists, { contact_ids: [] },
                                      { contact_profile_attributes: current_user.metadata.to_a },
                                      { contact_group_attributes: [:_id] })
    end

    def create_profile
      @contact.contact_profile ||= ContactProfile.new

      current_user.metadata.each do |metafield|
        @contact.contact_profile[metafield] ||= ''
      end
    end

    def duplicate_contact
      Contact.find_by(:$and => [ uid: @contact.uid, prefix: @contact.prefix, mobile: @contact.mobile ])
    end

    def import_contacts contacts
      # TODO Modify this according to threads running this piece of code
      progress_step = (100/contacts.size.to_f)/2

      inserted  = 0
      updated   = 0

      group_ids = {}

      contacts.each do |row_hash|
        uid = current_user.id
        contact_params = {}

        contact_params[:uid] = uid
        contact_params[:prefix] = row_hash.delete('prefix').to_i
        contact_params[:mobile] = row_hash.delete('mobile').to_i

        contact_group_ids = []
        groups = row_hash['groups'].split('/') unless row_hash['groups'].blank?

        unless groups.blank?
          groups.each do |group|
            group.strip!
            unless group_ids[group]
              grp = nil
              @mutex.synchronize do
                begin
                  grp = ContactGroup.find_by({ uid: current_user.id, label: group })
                rescue Mongoid::Errors::DocumentNotFound => exception
                  debug_inspect exception
                  grp = ContactGroup.create({ uid: uid, label: group })
                ensure
                  unless grp.nil?
                    group_bson_id = BSON::ObjectId.from_string(grp[:_id])
                    group_ids[group] = group_bson_id
                    contact_group_ids << group_bson_id
                  end
                end
              end
            else
              contact_group_ids << group_ids[group]
            end
          end
          row_hash.delete('groups')
        end

        contact_profile = Object.new
        @mutex.synchronize do
          contact_profile = ContactProfile.new(row_hash)
        end
        contact_profile_params = row_hash
        contact_profile_params[:_id] = contact_profile[:_id]
        contact_params['contact_profile'] = contact_profile_params
        contact_params['contact_group_ids'] = contact_group_ids

        result = Contact.collection.update_one({uid: contact_params[:uid], prefix: contact_params[:prefix], mobile: contact_params[:mobile]},
                                               {'$set' => contact_params, '$addToSet' => { lists: params[:contact][:contact_lists].original_filename }},
                                               {upsert: true})
                     .documents.first

        updated += result[:nModified]
        inserted += result[:n] unless result[:nModified].to_i > 0

        @mutex.synchronize do
          @i += 1
        end
        sfb = @i*progress_step % 2
        if sfb < 0.1 or (sfb > 1 and sfb < 1.1)
          @command_queue << { pc: @i.to_s, pg: (@i*progress_step).to_s }
        end
      end

      @command_queue << nil
      return { inserted: inserted, updated: updated }
    end

    def send_csv(data, filename)
      send_data generate_csv(data),
                :type => 'text/csv; charset=utf-8; header=present',
                :disposition => "attachment; filename=#{filename}.csv"
    end

    def send_xlsx(data, filename)
      send_data (generate_xlsx data).to_stream.read,
                :type => 'application/vnd.openxmlformates-officedocument.spreadsheetml.sheet',
                :disposition => "attachment; filename=#{filename}.xlsx"
    end
end
