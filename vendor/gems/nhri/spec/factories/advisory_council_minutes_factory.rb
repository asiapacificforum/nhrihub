FactoryGirl.define do
  factory :advisory_council_minutes, :class => Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes do
    file                { LoremIpsumDocument.new.docfile }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.docx" }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    date                { Faker::Time.between(1.year.ago, Time.now) }
    original_type       "docx"
    user_id { if User.count > 20 then User.pluck(:id).sample else FactoryGirl.create(:user, :with_password).id end }
  end
end
