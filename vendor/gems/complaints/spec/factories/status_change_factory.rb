FactoryGirl.define do
  factory :status_change do
    association :user

    trait :open do
      after(:create) do |status_change|
        status_change.complaint_status = ComplaintStatus.find_or_create_by(:name => "Open")
      end
    end

    trait :suspended do
      after(:create) do |status_change|
        status_change.complaint_status = ComplaintStatus.find_or_create_by(:name => "Suspended")
      end
    end

    trait :closed do
      after(:create) do |status_change|
        status_change.complaint_status = ComplaintStatus.find_or_create_by(:name => "Closed")
      end
    end
  end
end
