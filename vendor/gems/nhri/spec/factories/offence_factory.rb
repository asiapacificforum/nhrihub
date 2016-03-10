FactoryGirl.define do
  factory :offence, :class => Nhri::Indicator::Offence do
    description {Faker::Lorem.words(5).join(' ')}
    heading_id {Nhri::Indicator::Heading.pluck(:id).sample}
  end
end
