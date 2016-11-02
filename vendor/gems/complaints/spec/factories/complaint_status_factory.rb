FactoryGirl.define do
  factory :complaint_status do
    name  "oogly woo"

    trait :open do
      name  "open"
    end

    trait :closed do
      name "closed"
    end
  end
end
