FactoryGirl.define do
  factory :convention do
    # CONVENTIONS defined in lib/constants
    name { CONVENTIONS.keys.sample }
  end
end
