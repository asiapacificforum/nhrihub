FactoryGirl.define do
  factory :communication do
    mode ['phone','email','letter','face to face'].sample
    direction ['sent','received'].sample
    date { DateTime.now }
    user_id { if User.count > 20 then User.pluck(:id).sample else FactoryGirl.create(:user, :with_password).id end }
    after(:build) do |communication|
      communication.communication_documents << FactoryGirl.create(:communication_document)
      communication.communicants << FactoryGirl.create(:communicant)
    end

    trait :with_notes do
      after(:create) do |communication|
        2.times do
          FactoryGirl.create(:note, :communication, :notable_id => communication.id)
        end
      end
    end
  end
end
