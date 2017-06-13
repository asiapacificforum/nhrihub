def titles
  ["Statement of Compliance", "Enabling Legislation", "Organization Chart", "Annual Report", "Budget"]
end

namespace :nhri do
  namespace :accreditation do
    namespace :internal_documents do
      task :depopulate => :environment do
        AccreditationRequiredDoc.destroy_all
      end

      task :populate => "nhri:accreditation:internal_documents:depopulate" do
        #Rake::Task["nhri:accreditation:internal_documents:depopulate"].invoke
        titles.each do |title|
          current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
          doc = FactoryGirl.create(:accreditation_required_document, :revision => first_doc_rev.to_s, :title => title, :original_filename => rand_filename)
          dgid = doc.document_group_id
          5.times do |i|
            current_doc_rev -= 0.1
            current_doc_rev = current_doc_rev.round(1)
            FactoryGirl.create(:accreditation_required_document, :document_group_id => dgid, :revision => current_doc_rev.to_s, :title => title, :original_filename => rand_filename)
          end
        end
      end
    end

    desc "populates icc accreditation reference documents"
    namespace :reference_documents do
      task :depopulate => :environment do
        IccReferenceDocument.destroy_all
      end

      task :populate => "nhri:accreditation:reference_documents:depopulate" do
        5.times do |i|
          FactoryGirl.create(:icc_reference_document)
        end
      end
    end
  end
end
