FactoryGirl.define do
  factory :communication do
    mode ['phone','email','face_to_face'].sample
    direction ['sent','received'].sample
  end
end
