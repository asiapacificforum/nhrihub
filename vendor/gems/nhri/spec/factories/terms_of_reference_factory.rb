FactoryGirl.define do
  factory :terms_of_reference_version do
    file_id             { SecureRandom.hex(30) }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    revision_major      { rand(10) }
    revision_minor      { rand(9) }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    original_type       "application/msword"
    user


    after(:build) { |doc| FileUtils.touch Rails.root.join('tmp','uploads','store',doc.file_id)  }
  end
end
