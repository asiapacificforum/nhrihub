FactoryGirl.define do
  factory :impact_rating do
    attrs = Proc.new { ImpactRating::DefaultValues.sample }
    text { attrs.call.text }
    rank { attrs.call.rank }
  end
end
