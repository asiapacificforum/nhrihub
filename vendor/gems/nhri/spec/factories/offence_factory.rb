FactoryGirl.define do
  factory :offence, :class => Nhri::Indicator::Offence do
    description {Faker::Lorem.words(5).join(' ')}
    heading_id {Heading.pluck(:id).sample}
  end
end
