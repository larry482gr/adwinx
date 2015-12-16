class TemplatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_template, only: [:show, :edit, :update, :destroy]

    # GET /templates
    # GET /templates.json
    def index
      params[:limit] ||= Template::DEFAULT_PER_PAGE
      params[:limit] = Template::RESULTS_PER_PAGE.max unless params[:limit].to_i <= Contact::RESULTS_PER_PAGE.max
      @templates = Template.where(uid: current_user.id).asc(:label).page(params[:page]).per(params[:limit])
    end

    # GET /templates/1
    # GET /templates/1.json
    def show
    end

    # GET /templates/new
    def new
        @template = Template.new
    end

    # GET /templates/1/edit
    def edit
    end

      # POST /templates
      # POST /templates.json
    def create
    @template = Template.new(template_params)
    @template.uid = current_user.id

    respond_to do |format|
      begin
        if @template.save
          format.html { redirect_to templates_path, notice: 'Template was successfully created.' }
          format.json { render templates_path, status: :created }
        else
          format.html { render :new }
          format.json { render json: @template.errors, status: :unprocessable_entity }
        end
      rescue Mongo::Error::OperationFailure => exception
        @template = duplicate_group

        error = (t 'mongoid.errors.template.duplicate_val').gsub('%label%', @template.label)
        @template.errors[t 'mongoid.errors.template.duplicate_key'] = error

        format.html { render :edit }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end
    end

    # PATCH/PUT /templates/1
    # PATCH/PUT /templates/1.json
    def update
        respond_to do |format|
            begin
                if @template.update(template_params)
                  format.html { redirect_to @template, notice: 'Template was successfully updated.' }
                  format.json { render :show, status: :ok, location: @template }
                else
                  format.html { render :edit }
                  format.json { render json: @template.errors, status: :unprocessable_entity }
                end
            rescue Mongo::Error::OperationFailure => exception
                template = duplicate_group

                error = (t 'mongoid.errors.template.duplicate_val').gsub('%label%', @template.label)
                @template.errors[t 'mongoid.errors.template.duplicate_key'] = error

                format.html { render :edit }
                format.json { render json: @template.errors, status: :unprocessable_entity }
          end
        end
    end

    def destroy
      @template.destroy
      respond_to do |format|
        format.html { redirect_to templates_url, notice: 'Template was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    # POST /templates/bulk_delete
    # POST /templates/bulk_delete.json
    def bulk_delete
      template_ids = []
      template_params[:template_ids].each do |tid|
        template_ids << BSON::ObjectId.from_string(tid)
      end

      deleted = Template.where(uid: current_user.id).in(:_id => template_ids).delete_all

      respond_to do |format|
        format.js {}
        format.json { render json: { deleted: deleted } }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_template
        @template = Template.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def template_params
        params.require(:template).permit(:user_id, :account_id, :label, :msg_body)
    end

end
