FactoryGirl.define do
  factory :outcome do
    description { Faker::Lorem.words(6).join(" ") }
    association :planned_result
  end
end
