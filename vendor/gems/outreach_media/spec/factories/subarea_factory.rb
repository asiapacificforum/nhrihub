human_rights_subareas = ["Violation", "Education activities", "Office reports", "Universal periodic review", "CEDAW", "CRC", "CRPD"]
good_governance_subareas = ["Violation", "Office report", "Office consultations"]

FactoryGirl.define do
  factory :subarea do
  end

  trait :human_rights do
    name human_rights_subareas.sample
  end

  trait :good_governance do
    name good_governance_subareas.sample
  end

  trait :other do
    name "a subarea"
  end
end
