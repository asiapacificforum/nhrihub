FactoryGirl.define do
  factory :heading, :class => Nhri::Heading do
    title {Faker::Lorem.sentence}
  end
end
