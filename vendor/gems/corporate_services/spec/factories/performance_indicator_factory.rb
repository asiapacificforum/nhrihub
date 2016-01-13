FactoryGirl.define do
  factory :performance_indicator do
    description { Faker::Lorem.words(6).join(" ") }
    association :activity
  end
end
