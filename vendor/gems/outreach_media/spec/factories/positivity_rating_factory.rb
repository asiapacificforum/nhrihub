FactoryGirl.define do
  factory :positivity_rating do
      text {["Reflects very negatively on the office",
            "Reflects slightly negatively on the office",
            "Has no bearing on the office",
            "Reflects slightly positively on the office",
            "Reflects very positively on the office"].sample}
      rank {(1..5).to_a.sample}
  end
end
