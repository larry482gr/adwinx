class ContactGroupsController < ApplicationController
  include ContactsHelper

  before_action :authenticate_user!
  before_action :set_contact_group, only: [:show, :edit, :update, :remove_contacts, :destroy, :empty]

  # GET /contact_groups
  # GET /contact_groups.json
  def index
    params[:limit] ||= ContactGroup::DEFAULT_PER_PAGE
    params[:limit] = ContactGroup::RESULTS_PER_PAGE.max unless params[:limit].to_i <= ContactGroup::RESULTS_PER_PAGE.max
    @contact_groups = ContactGroup.where(uid: current_user.id).asc(:label)
                          .page(params[:page]).per(params[:limit])
  end

  # GET /typeahead_contact_groups
  # GET /typeahead_contact_groups.json
  def typeahead
    cgr = ContactGroup.where(uid: current_user.id)
                          .asc('label')

    contact_groups = []
    cgr.each do |con_gr|
      contact_groups << { _id: con_gr['_id'].to_s, lbl: con_gr['label'] }
    end

    respond_to do |format|
      format.js {}
      format.json { render json: contact_groups }
    end
  end

  # GET /contact_groups/1
  # GET /contact_groups/1.json
  def show
    params_hash = group_contacts_params unless params[:contact].nil?

    pars = get_filter_params params_hash

    params[:page] ||= 1
    params[:limit] ||= Contact::DEFAULT_PER_PAGE
    params[:limit] = Contact::RESULTS_PER_PAGE.max unless params[:limit].to_i <= Contact::RESULTS_PER_PAGE.max

    contact_ids = Rails.cache.fetch("#{contacts_url}?q=#{Digest::SHA1.hexdigest(pars.inspect)}",
                                    :tag => ["contact-filters-#{current_user.id}"]) do

      Contact.where('$and' => pars).pluck(:_id)
    end

    @contacts = Contact.includes(:contact_groups).where(:_id => { '$in' => contact_ids })
                    .asc('contact_profile.last_name').asc('contact_profile.first_name')
                    .page(params[:page]).per(params[:limit])

    if @contacts.size <= (params[:page].to_i*params[:limit].to_i - params[:limit].to_i)
      params[:page] = @contacts.num_pages
      redirect_to host: contacts_url, params: params and return
    end

    @metadata = current_user.metadata
    @filters_form_action = "/contact_groups/#{@contact_group[:_id]}"

    respond_to do |format|
      format.html { render :show }
      format.json { render json: { metadata: @metadata, contacts: @contacts, group: @contact_group } }
    end
  end

  # GET /contact_groups/new
  def new
    @contact_group = ContactGroup.new
  end

  # GET /contact_groups/1/edit
  def edit
  end

  # POST /contact_groups
  # POST /contact_groups.json
  def create
    @contact_group = ContactGroup.new(contact_group_params)
    @contact_group.uid = current_user.id

    respond_to do |format|
      begin
        if @contact_group.save
          format.html { redirect_to contacts_path, notice: 'Contact group was successfully created.' }
          format.json { render contacts_path, status: :created }
        else
          format.html { render :new }
          format.json { render json: @contact_group.errors, status: :unprocessable_entity }
        end
      rescue Mongo::Error::OperationFailure => exception
        @contact_group = duplicate_group

        error = (t 'mongoid.errors.contact_group.duplicate_val').gsub('%label%', @contact_group.label)
        @contact_group.errors[t 'mongoid.errors.contact_group.duplicate_key'] = error

        format.html { render :edit }
        format.json { render json: @contact_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contact_groups/1
  # PATCH/PUT /contact_groups/1.json
  def update
    respond_to do |format|
      begin
        if @contact_group.update(contact_group_params)
          format.html { redirect_to @contact_group, notice: 'Contact group was successfully updated.' }
          format.json { render :show, status: :ok, location: @contact_group }
        else
          format.html { render :edit }
          format.json { render json: @contact_group.errors, status: :unprocessable_entity }
        end
      rescue Mongo::Error::OperationFailure => exception
        contact_group = duplicate_group

        error = (t 'mongoid.errors.contact_group.duplicate_val').gsub('%label%', @contact_group.label)
        @contact_group.errors[t 'mongoid.errors.contact_group.duplicate_key'] =
            "#{error} <a href=\"#{contact_group_path contact_group}\">#{t 'view_contact_group'}</a>"

        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contact_groups/remove_contacts
  # PATCH/PUT /contact_groups/remove_contacts.json
  # Called through Contact Groups Show/View screen to remove selected contacts from the specified group.
  def remove_contacts
    pars = contact_group_params
    contact_ids = []
    pars[:contact_ids].each do |cid|
      contact_ids << BSON::ObjectId.from_string(cid)
    end

    removed = Contact.where(uid: current_user.id).in(:_id => contact_ids).pull(contact_group_ids: @contact_group[:_id])

    respond_to do |format|
      format.html { redirect_to @contact_group,
                                notice: "#{removed.documents.first[:nModified]}
                                #{(t :contacts_successfully_removed).gsub('%group_label%', @contact_group[:label])}." }
      format.json { render :show, status: :ok, location: @contact_group }
    end
  end

  # DELETE /contact_groups/remove_contacts
  # DELETE /contact_groups/remove_contacts.json
  # Called through Contact Groups List screen to empty the group
  def empty
    removed = empty_group(@contact_group[:_id])

    respond_to do |format|
      format.html { redirect_to contact_groups_url, notice: "#{removed.documents.first[:nModified]}
      #{(t :contacts_successfully_removed).gsub('%group_label%', @contact_group[:label])}." }
      format.json { head :no_content }
    end
  end

  # DELETE /contact_groups/1
  # DELETE /contact_groups/1.json
  def destroy
    notices = []
    if contact_group_params[:contacts_fate].to_i == 1
      deleted = contacts_doomed(@contact_group[:_id])
      notices << (t :group_only_contacts_deleted).gsub('%contacts_deleted%', "<strong>#{deleted.to_s}</strong>")
    end

    empty_group(@contact_group[:_id])

    label = @contact_group[:label]
    @contact_group.destroy
    notices << (t :contact_group_deleted).gsub('%group_label%', "<strong>#{label}</strong>")

    respond_to do |format|
      format.html { redirect_to contact_groups_url, notice: notices.reverse.join('<br/>') }
      format.json { head :no_content }
    end
  end

  # DELETE /contact_groups/bulk_delete
  # DELETE /contact_groups/bulk_delete.json
  def bulk_delete
    params = contact_group_params
    contacts_fate = params[:contacts_fate].to_i

    notices = []
    deleted = 0
    labels = []

    params[:contact_group_ids].each do |group_id|
      bson_id = BSON::ObjectId.from_string(group_id)

      deleted += contacts_doomed(bson_id) unless contacts_fate == 0

      empty_group(bson_id)

      group = ContactGroup.find(bson_id)
      labels << group[:label]
      group.destroy
    end

    notices << (t :contact_group_deleted).gsub('%group_label%', "<strong>#{labels.join(', ')}</strong>")
    notices << (t :group_only_contacts_deleted).gsub('%contacts_deleted%', "<strong>#{deleted.to_s}</strong>") unless contacts_fate == 0

    respond_to do |format|
      format.html { redirect_to contact_groups_url, notice: notices.join('<br/>') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact_group
      @contact_group = ContactGroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_group_params
      params.require(:contact_group).permit(:label, :description, { contact_ids: [] }, { contact_group_ids: [] }, :contacts_fate)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_contacts_params
      params.require(:contact).permit(:prefix, :mobile,
                                      { contact_profile_attributes: current_user.metadata.to_a },
                                      { contact_group_attributes: [:_id] })
    end

    def duplicate_group
      ContactGroup.find_by(:$and => [ uid: @contact_group.uid, label: @contact_group.label ])
    end

    def empty_group(contact_group)
      Contact.where(uid: current_user.id, contact_group_ids: contact_group)
          .pull(contact_group_ids: contact_group)
    end

    def contacts_doomed(contact_group)
      Contact.where(uid: current_user.id, contact_group_ids: { :$size => 1 }).in(contact_group_ids: contact_group)
          .delete
    end
end
