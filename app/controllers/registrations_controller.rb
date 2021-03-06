class RegistrationsController < Devise::RegistrationsController

  private

  def account_update_params
    params.require(:user).permit(:email, :password, :password_confirmation, :current_password, :metadata, :language_id)
  end
end