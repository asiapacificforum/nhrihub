FactoryGirl.define do
  factory :positivity_rating do
    attrs = Proc.new { PositivityRating::DefaultValues.sample }
    rank { attrs.call.rank }
  end
end
