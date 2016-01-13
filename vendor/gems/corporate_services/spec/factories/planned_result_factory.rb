FactoryGirl.define do
  factory :planned_result do
    description { Faker::Lorem.words(6).join(" ") }
    association :strategic_priority
  end
end
