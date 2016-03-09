FactoryGirl.define do
  factory :indicator, :class => Nhri::Indicator::Indicator do
    title {Faker::Lorem.sentence}
    offence_id {(Offence.pluck(:id)+[nil]).sample}
    nature {["Structural","Process","Outcomes"].sample}
    #monitor_text
    #numerical_monitor_method
  end
end
