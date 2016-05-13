FactoryGirl.define do
  factory :project_document do
    title { Faker::Lorem.words(7).join(' ') }
    file_id             { SecureRandom.hex(30) }
    after(:build) { |doc| FileUtils.touch Rails.root.join('tmp','uploads','store',doc.file_id)  }
  end
end
