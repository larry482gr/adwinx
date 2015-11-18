class ContactsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact, only: [:show, :edit, :update, :destroy, :belonging_groups]

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.where(uid: current_user.id)
                    .order('contact_profile.last_name' => 1, 'contact_profile.first_name' => 1)

    @contact_group = ContactGroup.new
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
    # TODO implement this properly using its relations and REMOVE this... hack!
    pars = contact_params
    pars[:uid] = current_user.id

    group_ids = []
    pars[:contact_group_attributes].each do |group|
      group_ids << group[:_id]
    end
    pars.delete(:contact_group_attributes)
    pars[:contact_group_ids] = group_ids
    # TODO implement this properly using its relations and REMOVE this... hack!

    @contact = Contact.new(pars)
    @contact.set(contact_group_ids: group_ids)

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
    # TODO implement this properly using its relations and REMOVE this... hack!
    pars = contact_params
    pars[:uid] = current_user.id

    group_ids = []
    pars[:contact_group_attributes].each do |group|
      group_ids << BSON::ObjectId.from_string(group[:_id])
    end
    pars.delete(:contact_group_attributes)
    # TODO implement this properly using its relations and REMOVE this... hack!

    @contact.set(contact_group_ids: group_ids)

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:prefix, :mobile,
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
