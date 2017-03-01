FactoryGirl.define do
  factory :performance_indicator do
    description { Faker::Lorem.words(6).join(" ") }

    trait :well_populated do
      after(:create) do |pi|
        MediaAppearance.create(:file, :title => Faker::Lorem.sentence(5), :performance_indicators => [pi])
        Project.create(:title => Faker::Lorem.sentence(5), :performance_indicators => [pi])
        2.times do
          pi.reminders << FactoryGirl.create(:reminder, :performance_indicator, :remindable_id => pi.id)
          pi.save
        end
      end
    end
  end
end
