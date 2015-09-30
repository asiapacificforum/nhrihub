FactoryGirl.define do
  factory :violation_severity do
    attrs = Proc.new { ViolationSeverity::DefaultValues.sample }
    text { attrs.call.text }
    rank { attrs.call.rank }
  end
end
