FactoryGirl.define do
  factory :project_document do
    title            { Faker::Lorem.words(7).join(' ') }
    file_id          { SecureRandom.hex(30) }
    filename         { Faker::Lorem.words(3).join('_')+".pdf" }
    original_type    "application/pdf"
    after(:build) { |doc| FileUtils.touch Rails.root.join('tmp','uploads','store',doc.file_id)  }
  end
end
