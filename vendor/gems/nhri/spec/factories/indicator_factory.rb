FactoryGirl.define do
  factory :indicator, :class => Nhri::Indicator do
    title {Faker::Lorem.sentence}
    human_rights_attribute_id {(Nhri::HumanRightsAttribute.pluck(:id)+[nil]).sample}
    heading_id {(Nhri::Heading.pluck(:id).sample)}
    nature {["Structural","Process","Outcomes"].sample}
    monitor_format { ["text", "numeric", "file"].sample }
    numeric_monitor_explanation {if monitor_format=="numeric" then Faker::Lorem.words(7).join(' ') else nil end }

    after(:build) do |indicator|
      indicator.reminders << FactoryGirl.create(:reminder, :indicator)
    end
  end
end
