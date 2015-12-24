FactoryGirl.define do
  factory :outreach_event_document do
    file_id             { SecureRandom.hex(30) }
    file_size            { 10000 + (30000*rand).to_i }
    file_filename   { "#{Faker::Lorem.words(2).join("_")}.pdf" }
    file_content_type       "application/pdf"

    after(:build) do |oed|
      path = Rails.env.production? ?
        Rails.root.join('..','..','shared') :
        Rails.root.join('tmp')
      FileUtils.touch path.join('uploads','store',oed.file_id) 
    end
  end
end
