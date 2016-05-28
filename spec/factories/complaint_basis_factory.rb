FactoryGirl.define do
  factory :complaint_basis do
    trait :siu do
      name { Siu::ComplaintBasis::DefaultNames.sample }
      type "Siu::ComplaintBasis"
    end

    trait :gg do
      name { GoodGovernance::ComplaintBasis::DefaultNames.sample }
      type "GoodGovernance::ComplaintBasis"
    end

    factory :siu_complaint_basis, :class => Siu::ComplaintBasis, :traits => [:siu]
    factory :good_governance_complaint_basis, :class => GoodGovernance::ComplaintBasis, :traits => [:gg]
  end
end
