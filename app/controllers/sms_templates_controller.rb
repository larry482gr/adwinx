class SmsTemplatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_sms_template, only: [:show, :edit, :update, :destroy]

    # GET /sms_templates
    # GET /sms_templates.json
    def index
      params[:limit] ||= SmsTemplate::DEFAULT_PER_PAGE
      params[:limit] = SmsTemplate::RESULTS_PER_PAGE.max unless params[:limit].to_i <= SmsTemplate::RESULTS_PER_PAGE.max
      @sms_templates = SmsTemplate.where(uid: current_user.id).asc(:label).page(params[:page]).per(params[:limit])
    end

    # GET /sms_templates/1
    # GET /sms_templates/1.json
    def show
    end

    # GET /sms_templates/new
    def new
        @sms_template = SmsTemplate.new
    end

    # GET /sms_templates/1/edit
    def edit
    end

      # POST /sms_templates
      # POST /sms_templates.json
    def create
        @sms_template = SmsTemplate.new(sms_template_params)
        @sms_template.uid = current_user.id

        respond_to do |format|
          begin
            if @sms_template.save
              format.html { redirect_to sms_templates_path, notice: 'SMS Template was successfully created.' }
              format.json { render sms_templates_path, status: :created }
            else
              format.html { render :new }
              format.json { render json: @sms_template.errors, status: :unprocessable_entity }
            end
          rescue Mongo::Error::OperationFailure => exception
            @sms_template = duplicate_group

            error = (t 'mongoid.errors.sms_template.duplicate_val').gsub('%label%', @sms_template.label)
            @sms_template.errors[t 'mongoid.errors.sms_template.duplicate_key'] = error

            format.html { render :edit }
            format.json { render json: @sms_template.errors, status: :unprocessable_entity }
          end
        end
    end

    # PATCH/PUT /sms_templates/1
    # PATCH/PUT /sms_templates/1.json
    def update
        respond_to do |format|
            begin
                if @sms_template.update(sms_template_params)
                  format.html { redirect_to @sms_template, notice: 'SMS Template was successfully updated.' }
                  format.json { render :show, status: :ok, location: @sms_template }
                else
                  format.html { render :edit }
                  format.json { render json: @sms_template.errors, status: :unprocessable_entity }
                end
            rescue Mongo::Error::OperationFailure => exception
                sms_template = duplicate_group

                error = (t 'mongoid.errors.sms_template.duplicate_val').gsub('%label%', @sms_template.label)
                @sms_template.errors[t 'mongoid.errors.sms_template.duplicate_key'] = error

                format.html { render :edit }
                format.json { render json: @sms_template.errors, status: :unprocessable_entity }
          end
        end
    end

    def destroy
      @sms_template.destroy
      respond_to do |format|
        format.html { redirect_to sms_templates_url, notice: 'SMS Template was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    # POST /sms_templates/bulk_delete
    # POST /sms_templates/bulk_delete.json
    def bulk_delete
      sms_template_ids = []
      sms_template_params[:sms_template_ids].each do |tid|
        sms_template_ids << BSON::ObjectId.from_string(tid)
      end

      deleted = SmsTemplate.where(uid: current_user.id).in(:_id => sms_template_ids).delete_all

      respond_to do |format|
          format.html { redirect_to sms_templates_url, notice: notice }
          format.json { head :no_content }
      end
    end

    private
        # Use callbacks to share common setup or constraints between actions.
        #def set_sms_template
        #    @sms_template = SmsTemplate.find(params[:id])
        #end
        def set_sms_template
          begin
            @sms_template = SmsTemplate.find_by(:_id => params[:id], :uid => current_user.id)
          rescue Mongoid::Errors::DocumentNotFound => e
            debug_inspect "Mongoid::Errors::DocumentNotFound: message: Document not found for class SmsTemplate with attributes {:_id=>\"#{params[:id]}\", :uid=>#{current_user.id}}."
            redirect_to sms_templates_url, alert: 'Documents Not Found!' and return
          end
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def sms_template_params
            params.require(:sms_template).permit(:uid, :account_id, :label, :msg_body, { sms_template_ids: [] })
        end

end
