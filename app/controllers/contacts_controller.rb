require 'thread'

class ContactsController < ApplicationController
  include ActionController::Live
  include ContactsHelper

  # before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :belonging_groups]

  # GET /contacts
  # GET /contacts.json
  def index
    pars_hash = contact_params unless params[:contact].nil?
    pars = []

    if pars_hash
      pars << { '$where' => "(/^#{pars_hash[:prefix]}/i).test(this.prefix + '')" } unless pars_hash[:prefix].blank?
      pars << { '$where' => "(/^#{pars_hash[:mobile]}/i).test(this.mobile + '')" } unless pars_hash[:mobile].blank?

      pars_hash[:contact_profile_attributes].each do |key, value|
        unless value.blank?
          pars << { '$where' => "(/^#{value}/i).test(this.contact_profile.#{key} + '')" }
        end
      end

      unless pars_hash[:contact_group_attributes].blank?
        contact_group_ids = []
        pars_hash[:contact_group_attributes].each { |group| contact_group_ids << BSON::ObjectId.from_string(group[:_id]) }

        pars << { contact_group_ids: { '$in' => contact_group_ids } }
      end
    end

    pars << { uid: current_user.id }

    params[:page] ||= 1
    params[:limit] ||= Contact::DEFAULT_PER_PAGE
    params[:limit] = Contact::RESULTS_PER_PAGE.max unless params[:limit].to_i <= Contact::RESULTS_PER_PAGE.max

    @contacts = Contact.includes(:contact_groups).where('$and' => pars)
                    .asc('contact_profile.last_name').asc('contact_profile.first_name')
                    .page(params[:page]).per(params[:limit])

    @metadata = current_user.metadata
    @groups   = ContactGroup.where(uid: current_user.id).asc('label')

    respond_to do |format|
      format.html { render :index }
      format.json { render json: { metadata: @metadata, contacts: @contacts } }
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
    Mongo::Logger.logger.level = ::Logger::INFO
    response.headers['Content-Type'] = 'text/event-stream'

    start_time = Time.now.to_f

    filetype = params[:contact][:contact_lists].content_type

    contacts = parse_contacts filetype

    if contacts.is_a? Hash and contacts[:invalid] and not contacts[:labels].blank?
      response.stream.write ({ result: "The file you are trying to import contains these invalid fields:<br/>
                                        #{contacts[:labels].join(', ')}<br/>
                                        Please check that they are defined in your <a href=\"/users/edit\">Profile Settings</a>.",
                               status: 450.to_s }).to_json
    elsif contacts.is_a? Hash and contacts[:missing] and not contacts[:labels].blank?
      response.stream.write ({ result: "The file you are trying to import does not contain #{contacts[:labels].count} mandatory field(s):<br/>
                                        #{contacts[:labels].join(', ')}",
                               status: 451.to_s }).to_json
    else
      total_contacts = contacts.size
      response.stream.write ({ result: "Processing...", total: total_contacts.to_s, status: 200.to_s }).to_json
      sleep 0.1

      # import_result = import_contacts contacts

      import_result_1, import_result_2, import_result_3, import_result_4 = { inserted: 0, updated: 0 }
      odd_contacts  = contacts.select.with_index { |_, i| i.odd? }
      even_contacts = contacts.select.with_index { |_, i| i.even? }


      @mutex = Mutex.new
      @i = 0

      t1 = Thread.new{
        import_result_1 = import_contacts odd_contacts.select.with_index { |_, i| i.even? }
      }

      t2 = Thread.new{
        import_result_2 = import_contacts odd_contacts.select.with_index { |_, i| i.odd? }
      }

      t3 = Thread.new{
        import_result_3 = import_contacts even_contacts.select.with_index { |_, i| i.even? }
      }

      t4 = Thread.new{
        import_result_4 = import_contacts even_contacts.select.with_index { |_, i| i.odd? }
      }

      t1.join
      t2.join
      t3.join
      t4.join

      total_inserted  = import_result_1[:inserted] + import_result_2[:inserted] +
                        import_result_3[:inserted] + import_result_4[:inserted]
      total_updated   = import_result_1[:updated] + import_result_2[:updated] +
                        import_result_3[:updated] + import_result_4[:updated]

      end_time = Time.now.to_f
      debug_inspect "Execution time: #{(end_time-start_time).to_s}"
      sleep 0.1
      response.stream.write ({ processed: (total_inserted + total_updated).to_s,
                               progress: (((total_inserted + total_updated)/total_contacts)*100).to_s,
                               result: "New: #{total_inserted.to_s} | Updated: #{total_updated.to_s}<br/>
                                        Execution time: #{(end_time-start_time).to_s}",
                               status: 200.to_s }).to_json
      sleep 0.1
    end
  ensure
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
      @contact = Contact.find(params[:id])
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
      progress_step = (100/contacts.size.to_f)/4

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

        contact_profile = ContactProfile.new(row_hash)
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
          if (@i*progress_step) % 2 < 0.1 or ((@i*progress_step) % 2 >= 1 and (@i*progress_step) % 2 < 1.1)
            response.stream.write ({ processed: @i.to_s, progress: (@i*progress_step).to_s }).to_json
            sleep 0.0001
          end
        end
      end

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
