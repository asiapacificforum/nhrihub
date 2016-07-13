FactoryGirl.define do
  factory :communication do
    mode ['phone','email','letter','face to face'].sample
    direction ['sent','received'].sample
    date { DateTime.now }
    association :user
    after(:build) do |communication|
      communication.communication_documents << FactoryGirl.create(:communication_document)
    end
  end
end
