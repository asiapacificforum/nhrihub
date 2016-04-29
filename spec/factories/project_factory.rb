FactoryGirl.define do
  factory :project do
    title { Faker::Lorem.words(7).join(' ') }
    description { Faker::Lorem.sentences(3).join(' ') }

    factory :good_governance_project do
      type "GoodGovernance::Project"
    end
  end
end
