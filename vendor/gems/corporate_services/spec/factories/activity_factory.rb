FactoryGirl.define do
  factory :activity do
    description { Faker::Lorem.words(6).join(" ") }
    association :outcome
  end
end
