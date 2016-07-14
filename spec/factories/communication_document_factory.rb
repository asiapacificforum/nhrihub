FactoryGirl.define do
  factory :communication_document do
    file_id             { SecureRandom.hex(30) }
    filesize            { 10000 + (30000*rand).to_i }
    filename            { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    original_type       "application/pdf"
    title               { "#{Faker::Lorem.words(8).join(" ")}" }

    after(:create) do |doc|
      `touch tmp/uploads/store/#{doc.file_id}`
    end
  end
end
