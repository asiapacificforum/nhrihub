FactoryGirl.define do
  factory :complaint do
    case_reference  "some string"
    complainant { Faker::Name.name }
    village { Faker::Address.city }
    phone { Faker::PhoneNumber.phone_number }
    created_at { DateTime.now.advance(:days => (rand(365) - 730))}

    trait :open do
      after(:build) do |complaint|
        complaint.status_changes = [FactoryGirl.create(:status_change)]
      end
    end

    trait :closed do
      after(:build) do |complaint|
        complaint.status_changes = [FactoryGirl.create(:status_change, :new_value => 0)]
      end
    end
  end
end
