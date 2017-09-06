FactoryGirl.define do
  factory :strategic_priority do
    strategic_plan_id { StrategicPlan.maximum(:id) }
    priority_level {StrategicPriority.where(:strategic_plan_id => strategic_plan_id).maximum(:priority_level) || 1}
    description    { Faker::Lorem.words(6).join(" ") }

    trait :populated do
      after(:create) do |sp|
        sp.planned_results << FactoryGirl.create(:planned_result, :populated, :strategic_priority_id => sp.id)
      end
    end

    trait :well_populated do
      after(:create) do |sp|
        sp.planned_results << FactoryGirl.create(:planned_result, :well_populated, :strategic_priority_id => sp.id)
        sp.planned_results << FactoryGirl.create(:planned_result, :well_populated, :strategic_priority_id => sp.id)
      end
    end
  end
end
