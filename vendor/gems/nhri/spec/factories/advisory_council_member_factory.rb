FactoryGirl.define do
  factory :advisory_council_member do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    title { Faker::Name.title }
    organization { "A Goverment Agency" }
    department { "A department" }
    mobile_phone { Faker::PhoneNumber.phone_number }
    office_phone { Faker::PhoneNumber.phone_number }
    home_phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
    alternate_email { Faker::Internet.email }
    bio { Faker::Lorem.sentences(2).join(' ') }
  end
end
