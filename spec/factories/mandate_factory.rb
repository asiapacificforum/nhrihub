FactoryGirl.define do
  factory :mandate do
    key [:human_rights, :good_governance, :special_investigations_unit].sample
  end
end
