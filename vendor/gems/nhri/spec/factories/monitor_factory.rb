FactoryGirl.define do
  factory :monitor, :class => Nhri::Indicator::Monitor do
    date { Date.today.advance(:days => -rand(365)) }
    description { Faker::Lorem.sentence }
  end
end
