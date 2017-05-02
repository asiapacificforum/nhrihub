FactoryGirl.define do
  factory :numeric_monitor, :class => Nhri::NumericMonitor do
    date { Date.today.advance(:days => -rand(365)) }
    value { [rand(50)+50, rand(5000)+1000].sample }
    author_id { if User.count > 20 then User.pluck(:id).sample else FactoryGirl.create(:user, :with_password).id end }
  end

  factory :text_monitor, :class => Nhri::TextMonitor do
    date { Date.today.advance(:days => -rand(365)) }
    description { Faker::Lorem.sentence }
    author_id { if User.count > 20 then User.pluck(:id).sample else FactoryGirl.create(:user, :with_password).id end }
  end

  factory :file_monitor, :class => Nhri::FileMonitor do
    file                { LoremIpsumDocument.new.docfile }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    original_type       "application/msword"
    user_id { if User.count > 20 then User.pluck(:id).sample else FactoryGirl.create(:user, :with_password).id end }
  end
end
