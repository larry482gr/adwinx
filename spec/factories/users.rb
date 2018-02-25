FactoryGirl.define do
  factory :user do
    email                 "test_user@example.com"
    password              "mysupersecretpass"
    password_confirmation "mysupersecretpass"
    language_id           1
  end
end
