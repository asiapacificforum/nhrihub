FactoryGirl.define do
  factory :note do
    text "88 notes on a piano"
    association :author, :factory => :user
    association :editor, :factory => :user
  end
end
