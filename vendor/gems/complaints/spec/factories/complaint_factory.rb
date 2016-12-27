FactoryGirl.define do
  factory :complaint do
    case_reference  "some string"
    firstName { Faker::Name.first_name }
    lastName { Faker::Name.last_name }
    village { Faker::Address.city }
    phone { Faker::PhoneNumber.phone_number }
    created_at { DateTime.now.advance(:days => (rand(365) - 730))}
    details { Faker::Lorem.paragraphs(2).join(" ") }
    chiefly_title { Faker::Name.last_name }
    occupation { Faker::Company.profession }
    employer { Faker::Company.name }

    trait :open do
      after(:build) do |complaint|
        complaint.status_changes = [FactoryGirl.create(:status_change, :open)]
      end
    end

    trait :closed do
      after(:build) do |complaint|
        complaint.status_changes = [FactoryGirl.create(:status_change, :closed)]
      end
    end
  end
end
