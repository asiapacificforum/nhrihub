# desc "Explaining what the task does"
# task :corporate_services do
#   # Task goes here
# end
namespace :corporate_services do
  desc "re-initialize database with 3 primary, 6 archive"
  task :init => :environment do
    DocumentGroup.delete_all
    InternalDocument.delete_all
    3.times do
      doc = FactoryGirl.create(:internal_document, :primary)
      dgid = doc.document_group_id
      first_archive = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgid)
      second_archive = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgid)
    end
  end
end
