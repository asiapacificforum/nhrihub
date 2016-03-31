FactoryGirl.define do
  factory :heading, :class => Nhri::Heading do
    title {Faker::Lorem.sentence}

    trait :with_offences do
      after(:create) do |heading|
        FactoryGirl.create(:offence, :heading_id => heading.id)
      end
    end
  end
end
