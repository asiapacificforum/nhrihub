FactoryGirl.define do
  factory :complaint_category do
    name { [ "Formal", "Out of Jurisdiction", "Informal"].sample }
  end
end
