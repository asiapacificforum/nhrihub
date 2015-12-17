FactoryGirl.define do
  factory :violation_severity do
    attrs = Proc.new { ViolationSeverity::DefaultValues.sample }
    rank { attrs.call.rank }
  end
end
