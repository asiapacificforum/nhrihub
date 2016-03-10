FactoryGirl.define do
  factory :indicator, :class => Nhri::Indicator::Indicator do
    title {Faker::Lorem.sentence}
    offence_id {(Nhri::Indicator::Offence.pluck(:id)+[nil]).sample}
    heading_id {(Nhri::Indicator::Heading.pluck(:id).sample)}
    nature {["Structural","Process","Outcomes"].sample}
    #monitor_text
    #numerical_monitor_method
  end
end
