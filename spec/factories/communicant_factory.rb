FactoryGirl.define do
  factory :communicant do
    name { Faker::Name.name }
    title_key %W{ Mr Ms Dr Capt }.sample
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.street_address }
    organization_id { Organization.pluck(:id).sample }
  end
end
