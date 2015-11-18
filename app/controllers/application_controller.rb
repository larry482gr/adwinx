class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  # before_action :set_locale

  rescue_from ActionController::UnpermittedParameters do |exception|
    flash[:alert] = 'Invalid parameters.'
    redirect_to :root
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

  def set_locale
    unless current_user.nil?
      begin
        language = current_user.language
        params[:locale] = language.locale
      rescue ActiveRecord::RecordNotFound
        params[:locale] = 'en'
      end
    end
    I18n.locale = params[:locale]
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def go_back
    redirect_to (session[:return_to] || root_path) and return
  end

  def debug_inspect (obj)
    puts "\n\n==============================\n"
    puts obj.inspect
    puts "\n==============================\n\n"
  end
end


=begin
========== Devise ==========

# Devise will create some helpers to use inside your controllers and views.
# To set up a controller with user authentication,
# just add this before_action (assuming your devise model is 'User'):
before_action :authenticate_user!

# If your devise model is something other than User, replace "_user" with "_yourmodel".
# The same logic applies to the instructions below.
# To verify if a user is signed in, use the following helper:
user_signed_in?

# For the current signed-in user, this helper is available:
current_user

# You can access the session for this scope:
user_session
========== Devise ==========

=end