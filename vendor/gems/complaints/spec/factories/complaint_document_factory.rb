FactoryGirl.define do
  factory :complaint_document do
    file                { LoremIpsumDocument.new.docfile }
    title               { Faker::Lorem.words(4).join(" ") }
    filesize            { 10000 + (30000*rand).to_i }
    filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    original_type       "application/pdf"

    after(:create) do |doc|
      `touch tmp/uploads/store/#{doc.file_id}`
    end
  end
end
