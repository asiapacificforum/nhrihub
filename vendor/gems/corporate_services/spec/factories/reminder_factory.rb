FactoryGirl.define do
  factory :reminder do
    text { Faker::Lorem.sentences(2) }
    reminder_type {["one-time", "weekly", "monthly", "quarterly", "semi-annually", "annually"].sample}
    start_date { Date.today.advance(:days => rand(365)) }
  end

  trait :media_appearance do
    remindable_type "MediaAppearance"
  end

  trait :activity do
    remindable_type "Activity"
  end
end
