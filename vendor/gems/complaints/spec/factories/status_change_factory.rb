FactoryGirl.define do
  factory :status_change do
    new_value 1
    association :user
  end
end
