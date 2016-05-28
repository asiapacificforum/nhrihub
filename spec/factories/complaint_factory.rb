FactoryGirl.define do
  factory :complaint do
    case_reference "some string"
    complainant { Faker::Name.name }
    village { Faker::Address.city }
    phone { Faker::PhoneNumber.phone_number }
  end
end
