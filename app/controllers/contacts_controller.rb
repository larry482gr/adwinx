class ContactsController < ApplicationController
  include ActionController::Live
  include ContactsHelper

  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :belonging_groups]

  # GET /contacts
  # GET /contacts.json
  def index
    params[:page] ||= 1
    params[:limit] ||= Contact::DEFAULT_PER_PAGE
    params[:limit] = Contact::RESULTS_PER_PAGE.max unless params[:limit].to_i <= Contact::RESULTS_PER_PAGE.max
    @contacts = Contact.includes(:contact_groups).where(uid: current_user.id)
                    .asc('contact_profile.last_name').asc('contact_profile.first_name')
                    .page(params[:page]).per(params[:limit])

    @metadata = current_user.metadata

    respond_to do |format|
      format.html { render :index }
      format.json { render json: { metadata: @metadata, contacts: @contacts } }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/csv_template
  def csv_template
    send_data generate_csv_template,
              :type => 'text/csv; charset=utf-8; header=present',
              :disposition => 'attachment; filename=csv_template.csv'
  end

  # GET /contacts/xlsx_template
  def xlsx_template
    send_data generate_xlsx_template.to_stream.read,
              :type => 'application/vnd.openxmlformates-officedocument.spreadsheetml.sheet',
              :disposition => 'attachment; filename=xlsx_template.xlsx'
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

  # POST /contacts/bulk_import
  def bulk_import
    Mongo::Logger.logger.level = ::Logger::INFO
    response.headers['Content-Type'] = 'text/event-stream'

    start_time = Time.now.to_f

    rows_hashes = []
    File.open(params[:contact][:contact_lists].tempfile, 'r') do |file|
      rows = file.read.split(/\r?\n/)
      arr_of_arrs = rows.collect { |row| row.split(',') }
      headers = arr_of_arrs.shift

      i = 0
      arr_of_arrs.each do |row|
        j = 0
        row_hash = {}
        headers.each do |header|
          row_hash[header] = row[j]
          j += 1
        end
        rows_hashes << row_hash
        i += 1
      end
    end

    # debug_inspect rows
    # debug_inspect arr_of_arrs
    # arr_of_arrs = CSV.read(params[:contact][:contact_lists].tempfile, headers: true)

    total_contacts = rows_hashes.size
    response.stream.write ({ total: total_contacts.to_s }).to_json
    sleep 0.1

    progress_step = 100/total_contacts.to_f
    i = 0

    inserted  = 0
    updated   = 0

    group_ids = {}

    rows_hashes.each do |row_hash|
      # row_hash = row #.to_hash

      uid = current_user.id
      contact_params = {}

      contact_params[:uid] = uid
      contact_params[:prefix] = row_hash.delete('prefix').to_i
      contact_params[:mobile] = row_hash.delete('mobile').to_i

      contact_group_ids = []
      groups = row_hash['groups'].split('/')

      unless groups.blank?
        groups.each do |group|
          group.strip!
          unless group_ids[group]
            grp = nil
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

      # debug_inspect result

      updated += result[:nModified]
      inserted += result[:n] unless result[:nModified].to_i > 0

      i += 1
      if ((i*progress_step) % 2).is_a? Integer or (i*progress_step) % 2 < 0.1 or
          ((i*progress_step) % 2 > 1 and (i*progress_step) % 2 < 1.1)
        response.stream.write ({ processed: i.to_s, progress: (i*progress_step).to_s }).to_json
        sleep 0.00001
      end
    end

    end_time = Time.now.to_f
    sleep 0.1
    response.stream.write ({ processed: i.to_s, progress: (i*progress_step).to_s }).to_json
    sleep 0.1
    response.stream.write ({ final_result: "in #{sprintf('%.3f', end_time-start_time).to_s} sec. - Inserted: #{inserted.to_s} | Updated: #{updated.to_s}" }).to_json
    sleep 0.01
    response.stream.close
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
end
