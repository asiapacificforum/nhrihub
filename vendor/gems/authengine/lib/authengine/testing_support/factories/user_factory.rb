require 'faker'

FactoryGirl.define do
  factory :user do
    login {Faker::Name.last_name}
    email {Faker::Internet.email}
    activated_at {Date.today - rand(365)}
    enabled 1
    firstName {Faker::Name.first_name}
    lastName {Faker::Name.last_name}

    association :organization, :pantry, strategy: :create

    trait :admin do
      after(:build) do |u|
        if Role.exists?(:name => 'admin')
          u.roles. << Role.where(:name => 'admin').first
        else
          u.roles << FactoryGirl.build(:admin_role)
        end
      end
    end

    trait :staff do
      after(:build) do |u|
        if Role.exists?(:name => 'staff')
          u.roles << Role.where(:name => 'staff').first
        else
          u.roles << FactoryGirl.build(:staff_role)
        end
      end
    end
  end

end
