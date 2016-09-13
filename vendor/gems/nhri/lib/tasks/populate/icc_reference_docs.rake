namespace :nhri do
  desc "populates icc accreditation reference documents"
  task :populate_ref_docs => :environment do
    IccReferenceDocument.destroy_all
    5.times do |i|
      FactoryGirl.create(:icc_reference_document)
    end
  end
end
