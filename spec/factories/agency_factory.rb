FactoryGirl.define do
  factory :agency do
    key = AGENCIES.keys.sample
    name { key }
    full_name AGENCIES[key]
  end
end
