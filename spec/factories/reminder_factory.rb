FactoryGirl.define do
  factory :reminder do
    text { Faker::Lorem.sentences(2).join(' ') }
    reminder_type {["one-time", "weekly", "monthly", "quarterly", "semi-annual", "annual"].sample}
    start_date { Date.today.advance(:days => rand(365)) }
    user_id { if User.count > 20 then User.pluck(:id).sample else FactoryGirl.create(:user, :with_password).id end }

    trait :due_today do
      reminder_type "one-time"
      start_date { DateTime.now }
      after(:create) do |reminder|
        reminder.user = User.first
        reminder.save
      end
    end

    trait :media_appearance do
      remindable_type "MediaAppearance"
    end

    trait :advisory_council_issue do
      remindable_type "Nhri::AdvisoryCouncil::AdvisoryCouncilIssue"
    end

    trait :indicator do
      remindable_type "Nhri::Heading:Indicator"
    end

    trait :project do
      remindable_type "Project"
    end

    trait :complaint do
      remindable_type "Complaint"
    end

    trait :performance_indicator do
      remindable_type "PerformanceIndicator"
    end

    trait :icc do
      remindable_type "IccReferenceDocument"
    end
  end
end
