FactoryGirl.define do
  factory :offence, :class => Nhri::Offence do
    description {Faker::Lorem.words(5).join(' ')}
    heading_id {Nhri::Heading.pluck(:id).sample}
  end
end
