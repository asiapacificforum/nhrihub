# desc "Explaining what the task does"
# task :corporate_services do
#   # Task goes here
# end
namespace :corporate_services do
  desc "re-initialize database with 5 primary, 10 archive"
  task :init => :environment do
    DocumentGroup.delete_all
    InternalDocument.delete_all
    5.times do
      first_doc_rev = (rand(49)+50).to_f/10
      doc = FactoryGirl.create(:internal_document, :revision => first_doc_rev.to_s)
      dgid = doc.document_group_id
      first_archive_rev = (rand(30)+20).to_f/10
      first_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => first_archive_rev.to_s)
      second_archive_rev = (rand(20)).to_f/10
      second_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => second_archive_rev.to_s)
    end
  end
end
