class SmsCampaignsController < ApplicationController

  # before_action :authenticate_user!
  before_action :set_sms_campaign, only: [:show, :edit, :update, :destroy]

  # GET /sms_campaigns
  # GET /sms_campaigns.json
  def index
    @sms_campaigns = SmsCampaign.all
  end

  # GET /sms_campaigns/1
  # GET /sms_campaigns/1.json
  def show
  end

  # GET /sms_campaigns/new
  def new
    @sms_campaign = SmsCampaign.new
  end

  # GET /sms_campaigns/1/edit
  def edit
  end

  # POST /sms_campaigns
  # POST /sms_campaigns.json
  def create
    # pars = sms_campaign_params
    # recipients  = pars.delete(:sms_campaign_recipients_attributes)
    # camp_pars   = pars
    @sms_campaign = SmsCampaign.new(sms_campaign_params)
    # @sms_campaign.sms_recipient_list.new(recipients)

    respond_to do |format|
      if @sms_campaign.save
        format.html { redirect_to @sms_campaign, notice: 'Sms campaign was successfully created.' }
        format.json { render :show, status: :created, location: @sms_campaign }
      else
        format.html { render :new }
        format.json { render json: @sms_campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sms_campaigns/1
  # PATCH/PUT /sms_campaigns/1.json
  def update
    respond_to do |format|
      if @sms_campaign.update(sms_campaign_params)
        format.html { redirect_to @sms_campaign, notice: 'Sms campaign was successfully updated.' }
        format.json { render :show, status: :ok, location: @sms_campaign }
      else
        format.html { render :edit }
        format.json { render json: @sms_campaign.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sms_campaigns/1
  # DELETE /sms_campaigns/1.json
  def destroy
    @sms_campaign.destroy
    respond_to do |format|
      format.html { redirect_to sms_campaigns_url, notice: 'Sms campaign was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sms_campaign
      @sms_campaign = SmsCampaign.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sms_campaign_params
      params.require(:sms_campaign).permit(:label, :originator, :msg_body,
                                           :start_date, :end_date,
                                           :restriction_start_date, :restriction_end_date,
                                           :encoding, :on_screen, :state,
                                           :sms_recipient_list_attributes => { contacts: [], contact_groups: [] })
    end
end
