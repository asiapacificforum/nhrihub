FactoryGirl.define do
  factory :strategic_priority do
    priority_level {StrategicPriority.maximum(:priority_level) || 1}
    description    { Faker::Lorem.words(6).join(" ") }
    strategic_plan_id { StrategicPlan.maximum(:id) }
  end
end
