FactoryGirl.define do
  factory :internal_document do
     file_id             { SecureRandom.hex(30) }
     title               { Faker::Lorem.words(4).join(" ") }
     filesize            { 10000 + (30000*rand).to_i }
     original_filename   { "my_test_file.pdf" }
     revision_major      { rand(10) }
     revision_minor      { rand(9) }
     lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
     original_type       "application/pdf"

     after(:build) { |doc| FileUtils.touch Rails.root.join('tmp','uploads','store',doc.file_id)  }
  end
end
