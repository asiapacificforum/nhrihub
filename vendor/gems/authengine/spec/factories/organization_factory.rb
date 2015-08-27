FactoryGirl.define  do
  factory :organization do
    name { Faker::Company.name }
    street  { Faker::Address.street_address }
    city  { Faker::Address.city }
    zip  { Faker::Address.zip_code }
    phone  {Faker::PhoneNumber.phone_number}
    email  {Faker::Internet.email}
    contacts {ContactList.new([])}

    trait :with_users do
      after(:build) do |o|
        o.users << FactoryGirl.build(:user, :organization_id => o.id)
      end
    end
  end
end
