FactoryGirl.define do
  factory :offence, :class => Nhri::Heading::Offence do
    description {Faker::Lorem.words(5).join(' ')}
    heading_id {Nhri::Heading.pluck(:id).sample}
  end
end
