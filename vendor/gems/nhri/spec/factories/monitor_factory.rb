FactoryGirl.define do
  factory :numeric_monitor, :class => Nhri::NumericMonitor do
    date { Date.today.advance(:days => -rand(365)) }
    value { [rand(50)+50, rand(5000)+1000].sample }
    author_id { User.pluck(:id).sample }
  end

  factory :text_monitor, :class => Nhri::TextMonitor do
    date { Date.today.advance(:days => -rand(365)) }
    description { Faker::Lorem.sentence }
    author_id { User.pluck(:id).sample }
  end

  factory :file_monitor, :class => Nhri::FileMonitor do
    file                { LoremIpsumDocument.new.docfile }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    original_type       "application/msword"
    user_id { User.pluck(:id).sample }
  end
end
