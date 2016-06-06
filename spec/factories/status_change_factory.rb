FactoryGirl.define do
  factory :status_change do
    new_value 1
    user_id { User.all.sample.id }
  end
end
