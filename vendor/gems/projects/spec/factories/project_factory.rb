FactoryGirl.define do
  factory :project do
    title { Faker::Lorem.words(7).join(' ') }
    description { Faker::Lorem.sentences(3).join(' ') }

    trait :with_reminders do
      after(:build) do |project|
        project.reminders << FactoryGirl.create(:reminder, :project)
      end
    end

    trait :with_documents do
      after(:build) do |project|
        project.project_documents << FactoryGirl.build(:project_document)
        project.project_documents << FactoryGirl.build(:project_document)
      end
    end

    trait :with_named_documents do
      after(:build) do |project|
        project.project_documents << FactoryGirl.build(:project_document, :title => "Final Report")
        project.project_documents << FactoryGirl.build(:project_document, :title => "Project Document")
      end
    end

    trait :with_performance_indicators do
      after(:build) do |project|
        project.performance_indicator_ids = PerformanceIndicator.pluck(:id).last(3)
      end
    end

    trait :with_mandates do 
      after(:build) do |project|
        project.mandate_ids = Mandate.pluck(:id)
      end
    end

    trait :with_project_types do 
      after(:build) do |project|
        project.project_type_ids = ProjectType.pluck(:id)
      end
    end

  end
end
