FactoryGirl.define do
  factory :terms_of_reference_version, :class => Nhri::AdvisoryCouncil::TermsOfReferenceVersion do
    file                { LoremIpsumDocument.new.docfile }
    filesize            { 10000 + (30000*rand).to_i }
    original_filename   { "#{Faker::Lorem.words(2).join("_")}.docx" }
    revision_major      { rand(10) }
    revision_minor      { rand(9) }
    lastModifiedDate    { Faker::Date.between(1.year.ago, Date.today) }
    original_type       "docx"

    after(:build) { |doc| doc.user = User.all.sample }
  end
end
