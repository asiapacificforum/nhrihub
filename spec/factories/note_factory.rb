FactoryGirl.define do
  factory :note do
    text { Faker::Lorem.sentence(10) }
    author_id { if User.count > 100 then User.pluck(:id).sample else FactoryGirl.create(:user).id end }
    editor_id { if User.count > 100 then User.pluck(:id).sample else FactoryGirl.create(:user).id end }

    trait :media_appearance do
      notable_type "MediaAppearance"
    end

    trait :outreach_event do
      notable_type "OutreachEvent"
    end

    trait :activity do
      notable_type "Activity"
    end

    trait :advisory_council_issue do
      notable_type "Nhri::AdvisoryCouncil::AdvisoryCouncilIssue"
    end

    trait :indicator do
      notable_type "Nhri::Heading:Indicator"
    end

    trait :good_governance_project do
      notable_type "GoodGovernance::Project"
    end

    trait :siu_project do
      notable_type "Siu::Project"
    end
  end
end
