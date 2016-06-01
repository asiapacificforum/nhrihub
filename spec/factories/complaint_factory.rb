FactoryGirl.define do
  factory :complaint do
    case_reference  "some string"
    complainant { Faker::Name.name }
    village { Faker::Address.city }
    phone { Faker::PhoneNumber.phone_number }
    status  { [true,false].sample }
    closed_by  {!status && User.all.sample}
    created_at { DateTime.now.advance(:days => (rand(365) - 730))}
    closed_on  {!status && DateTime.now.advance(:days => -rand(DateTime.now-created_at))}
  end
end
