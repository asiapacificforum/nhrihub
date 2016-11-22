FactoryGirl.define do
  factory :advisory_council_minutes, :class => Nhri::AdvisoryCouncil::AdvisoryCouncilMinutes do
    file_id             { SecureRandom.hex(30) }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    date                { Faker::Time.between(1.year.ago, Time.now) }
    original_type       "application/msword"
    user


    after(:build) { |doc| FileUtils.touch Rails.root.join('tmp','uploads','store',doc.file_id)  }
  end
end
