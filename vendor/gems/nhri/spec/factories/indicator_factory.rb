FactoryGirl.define do
  factory :indicator, :class => Nhri::Indicator::Indicator do
    title {Faker::Lorem.sentence}
    offence_id {(Nhri::Indicator::Offence.pluck(:id)+[nil]).sample}
    heading_id {(Nhri::Indicator::Heading.pluck(:id).sample)}
    nature {["Structural","Process","Outcomes"].sample}
    monitor_format { ["percent", "int", "text"].sample }
    numerical_monitor_description {if /percent|int/ =~ monitor_format then Faker::Lorem.words(7).join(' ') else nil end }
  end
end
