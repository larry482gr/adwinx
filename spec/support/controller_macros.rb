FactoryGirl.define do
  factory :language do
    id                    1
    locale                "en"
    language              "english"
  end
end

FactoryGirl.define do
  factory :user do
    email                 "test_user@example.com"
    password              "mysupersecretpass"
    password_confirmation "mysupersecretpass"
    language_id           1
  end
end

module ControllerMacros
=begin
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(:admin) # Using factory girl as an example
    end
  end
=end

  def create_english_lang
    before(:each) do
      FactoryGirl.create(:language)
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = FactoryGirl.create(:user)
      user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the "confirmable" module
      sign_in user
    end
  end
end