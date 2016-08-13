FactoryGirl.define do
  factory :icc_reference_document do
    title  {Faker::Lorem.words(4).join(' ')}
    file_id             { SecureRandom.hex(30) }
    source_url          { Faker::Internet.url }
    filesize            { rand(1000000) + 10000 }
    original_filename   { Faker::Lorem.words(4).join('_')+'.pdf' }
    original_type       { "application/pdf" }

    after(:build) { |doc|
      doc.user = FactoryGirl.create(:user, :with_password)
      FileUtils.touch Rails.root.join('tmp','uploads','store',doc.file_id)
    }
  end
end
