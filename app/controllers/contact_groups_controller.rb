class ContactGroupsController < ApplicationController
  before_action :set_contact_group, only: [:show, :edit, :update, :destroy]

  # GET /contact_groups
  # GET /contact_groups.json
  def index
    @contact_groups = ContactGroup.all
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

    respond_to do |format|
      if @contact_group.save
        format.html { redirect_to @contact_group, notice: 'Contact group was successfully created.' }
        format.json { render :show, status: :created, location: @contact_group }
      else
        format.html { render :new }
        format.json { render json: @contact_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contact_groups/1
  # PATCH/PUT /contact_groups/1.json
  def update
    respond_to do |format|
      if @contact_group.update(contact_group_params)
        format.html { redirect_to @contact_group, notice: 'Contact group was successfully updated.' }
        format.json { render :show, status: :ok, location: @contact_group }
      else
        format.html { render :edit }
        format.json { render json: @contact_group.errors, status: :unprocessable_entity }
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
end
