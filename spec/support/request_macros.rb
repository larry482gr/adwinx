module RequestMacros

  def login_valid_user
    user = FactoryGirl.create(:user)
    user.confirm

    # We action the login request using the parameters before we begin.
    # The login requests will match these to the user we just created in the factory, and authenticate us.
    post_via_redirect user_session_path, 'user[email]' => user.email, 'user[password]' => user.password
  end
end
