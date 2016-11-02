FactoryGirl.define do
  factory :status_change do
    association :user

    trait :open do
      after(:create) do |status_change|
        status_change.complaint_status = FactoryGirl.create(:complaint_status, :open)
      end
    end

    trait :closed do
      after(:create) do |status_change|
        status_change.complaint_status = FactoryGirl.create(:complaint_status, :closed)
      end
    end
  end
end
