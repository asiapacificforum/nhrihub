FactoryGirl.define do
  factory :complaint_document do
    file_id             { SecureRandom.hex(30) }
    title               { Faker::Lorem.words(4).join(" ") }
    filesize            { 10000 + (30000*rand).to_i }
    filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    original_type       "application/pdf"

    after(:build) { |doc| FileUtils.touch Rails.root.join('tmp','uploads','store',doc.file_id)  }
  end
end
