FactoryGirl.define do
  factory :project do
    title { Faker::Lorem.words(7).join(' ') }
    description { Faker::Lorem.sentences(3).join(' ') }
    after(:build) { |project| project.project_documents << [FactoryGirl.build(:project_document),FactoryGirl.build(:project_document)]}

    factory :good_governance_project do
      type "GoodGovernance::Project"
    end
  end
end
