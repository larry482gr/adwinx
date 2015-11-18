class ContactGroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact_group, only: [:show, :edit, :update, :destroy]

  # GET /contact_groups
  # GET /contact_groups.json
  def index
    @contact_groups = ContactGroup.where(uid: current_user.id)
                          .order('label' => 1)
  end

  # GET /typeahead_contact_groups
  # GET /typeahead_contact_groups.json
  def typeahead
    cgr = ContactGroup.where(uid: current_user.id)
                          .order('label' => 1)

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

  # DELETE /contact_groups/1
  # DELETE /contact_groups/1.json
  def destroy
    @contact_group.destroy
    respond_to do |format|
      format.html { redirect_to contact_groups_url, notice: 'Contact group was successfully destroyed.' }
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
      params.require(:contact_group).permit(:label, :description)
    end

    def duplicate_group
      ContactGroup.find_by(:$and => [ uid: @contact_group.uid, label: @contact_group.label ])
    end
end
