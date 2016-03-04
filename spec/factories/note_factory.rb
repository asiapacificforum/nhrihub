FactoryGirl.define do
  factory :note do
    text { Faker::Lorem.sentence(10) }
    association :author, :factory => :user
    association :editor, :factory => :user

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
  end
end
