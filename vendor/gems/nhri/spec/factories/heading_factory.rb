FactoryGirl.define do
  factory :heading, :class => Nhri::Indicator::Heading do
    title {Faker::Lorem.sentence}
  end
end
