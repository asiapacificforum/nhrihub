require 'rspec/core/shared_context'

module IccSetupHelper
  extend RSpec::Core::SharedContext
  def setup_database
   ["Budget", "Annual Report", "Organization Chart", "Enabling Legislation", "Statement of Compliance"].each do |title|
     FactoryGirl.create(:accreditation_document_group, :title => title)
   end


    current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
    doc = FactoryGirl.create(:accreditation_required_document,
                             :revision => first_doc_rev.to_s,
                             :title => "Statement of Compliance",
                             :original_filename => Faker::Lorem.words(3).join('_')+'.doc')
    dgid = doc.document_group_id
    4.times do |i|
      current_doc_rev -= 0.1
      current_doc_rev = current_doc_rev.round(1)
      FactoryGirl.create(:accreditation_required_document,
                         :document_group_id => dgid,
                         :revision => current_doc_rev.to_s,
                         :title => "Statement of Compliance",
                         :original_filename => Faker::Lorem.words(3).join('_')+'.doc')
    end
  end
end
