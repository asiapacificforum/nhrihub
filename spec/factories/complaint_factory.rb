FactoryGirl.define do
  factory :complaint do
    case_reference "some string"
    complainant { Faker::Name.name }

    trait :siu do
      type "Siu::Complaint"
    end

    trait :nhri do
      type "Nhri::Complaint"
    end

    trait :gg do
      type "GoodGovernance::Complaint"
    end
  end
end
