FactoryGirl.define do
  factory :advisory_council_minutes, :class => Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes do
    file_id             { SecureRandom.hex(30) }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.docx" }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    date                { Faker::Time.between(1.year.ago, Time.now) }
    original_type       "docx"
    user_id             { User.all.sample.id }
  end
end
