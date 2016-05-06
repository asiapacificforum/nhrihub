FactoryGirl.define do
  factory :heading, :class => Nhri::Heading do
    title {Faker::Lorem.sentence}

    trait :with_human_rights_attributes do
      after(:create) do |heading|
        FactoryGirl.create(:human_rights_attribute, :heading_id => heading.id)
      end
    end

    trait :with_three_human_rights_attributes do
      after(:create) do |heading|
        3.times do
          FactoryGirl.create(:human_rights_attribute, :heading_id => heading.id)
        end
      end
    end
  end
end
