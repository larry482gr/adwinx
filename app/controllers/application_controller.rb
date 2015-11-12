class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
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