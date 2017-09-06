FactoryGirl.define do
  factory :activity do
    description { Faker::Lorem.words(6).join(" ") }

    trait :populated do
      after(:create) do |a|
        a.performance_indicators << FactoryGirl.create(:performance_indicator, :activity_id => a.id)
      end
    end

    trait :well_populated do
      after(:create) do |a|
        a.performance_indicators << FactoryGirl.create(:performance_indicator, :well_populated, :activity_id => a.id)
        a.performance_indicators << FactoryGirl.create(:performance_indicator, :well_populated, :activity_id => a.id)
      end
    end
  end
end
