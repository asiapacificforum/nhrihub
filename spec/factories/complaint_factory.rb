FactoryGirl.define do
  factory :complaint do
    case_reference  "some string"
    complainant { Faker::Name.name }
    village { Faker::Address.city }
    phone { Faker::PhoneNumber.phone_number }
    created_at { DateTime.now.advance(:days => (rand(365) - 730))}
  end
end
