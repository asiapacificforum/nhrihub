FactoryGirl.define do
  factory :reminder do
    text { Faker::Lorem.sentences(2).join(' ') }
    reminder_type {["one-time", "weekly", "monthly", "quarterly", "semi-annually", "annually"].sample}
    start_date { Date.today.advance(:days => rand(365)) }

    trait :media_appearance do
      remindable_type "MediaAppearance"
    end

    trait :outreach_event do
      remindable_type "OutreachEvent"
    end

    trait :activity do
      remindable_type "Activity"
    end

    trait :advisory_council_issue do
      remindable_type "Nhri::AdvisoryCouncil::AdvisoryCouncilIssue"
    end

    trait :indicator do
      remindable_type "Nhri::Heading:Indicator"
    end

    trait :good_governance_project do
      remindable_type "GoodGovernance::Project"
    end
  end
end
