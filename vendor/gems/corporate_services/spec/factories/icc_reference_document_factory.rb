FactoryGirl.define do
  factory :icc_reference_document do
    title  {Faker::Lorem.words(4).join(' ')}
  end
end
