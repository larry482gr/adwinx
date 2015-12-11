FactoryGirl.define do
  factory :contact do
    uid                 1
    prefix              30
    mobile              1234567890
  end
end

FactoryGirl.define do
  factory :contact_profile do
    first_name          'Laz'
    last_name           'Kaz'
  end
end
