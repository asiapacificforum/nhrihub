FactoryGirl.define do
  factory :complaint_status do
    name  "oogly woo"

    trait :open do
      name  "Open"
    end

    trait :suspended do
      name "Suspended"
    end

    trait :closed do
      name "Closed"
    end
  end
end
