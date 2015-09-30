FactoryGirl.define do
  factory :positivity_rating do
    attrs = Proc.new { PositivityRating::DefaultValues.sample }
    text { attrs.call.text }
    rank { attrs.call.rank }
  end
end
