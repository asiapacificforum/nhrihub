FactoryGirl.define do
  factory :internal_document do
    #file_id             { SecureRandom.hex(30) }
    file                { LoremIpsumDocument.new.docfile }
    title               { Faker::Lorem.words(4).join(" ") }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.docx" }
    revision_major      { rand(10) }
    revision_minor      { rand(9) }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    original_type       "docx"
    type                nil
    user


    #after(:build) do |doc|
      #archive_filename = Rails.root.join('tmp','uploads','store',doc.file_id) 
      #file = LoremIpsumDocument.new
      #FileUtils.touch filename
    #end

    trait :null_revision do
      revision_major nil
      revision_minor nil
    end

  end

  factory :accreditation_required_document, :parent => :internal_document, :class => AccreditationRequiredDoc do
    type "AccreditationRequiredDoc"
    title { ["Statement of Compliance", "Enabling Legislation", "Organization Chart", "Annual Report", "Budget"].sample }
  end

end

