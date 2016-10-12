FactoryGirl.define do
  factory :planned_result do
    description { Faker::Lorem.words(6).join(" ") }
    #association :strategic_priority

    trait :populated do
      after(:create) do |pr|
        pr.outcomes << FactoryGirl.create(:outcome, :populated, :planned_result_id => pr.id)
      end
    end
  end
end
