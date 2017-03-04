FactoryGirl.define do
  factory :indicator, :class => Nhri::Indicator do
    title {Faker::Lorem.sentence}
    human_rights_attribute_id {(Nhri::HumanRightsAttribute.pluck(:id)+[nil]).sample}
    heading_id {(Nhri::Heading.pluck(:id).sample)}
    nature {["Structural","Process","Outcomes"].sample}
    monitor_format { ["text", "numeric", "file"].sample }
    numeric_monitor_explanation {if monitor_format=="numeric" then Faker::Lorem.words(7).join(' ') else nil end }

    trait :with_reminder do
      after(:build) do |indicator|
        reminder = FactoryGirl.create(:reminder,
                                        :indicator,
                                        :reminder_type => :weekly,
                                        :text => "don't forget the fruit gums mum",
                                        :user => User.first)
        indicator.reminders << reminder
      end
    end

    trait :with_notes do
      after(:build) do |indicator|
        indicator.notes << FactoryGirl.create(:note, :indicator, :created_at => 3.days.ago.to_datetime)
        indicator.notes << FactoryGirl.create(:note, :indicator, :created_at => 4.days.ago.to_datetime)
      end
    end
  end
end
