FactoryGirl.define do
  factory :human_rights_attribute, :class => Nhri::HumanRightsAttribute do
    description {Faker::Lorem.words(5).join(' ')}
    heading_id {Nhri::Heading.pluck(:id).sample}
  end
end
