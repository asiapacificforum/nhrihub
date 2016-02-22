require 'rspec/core/shared_context'

module AdvisoryCouncilTermsOfReferenceSetupHelper
  extend RSpec::Core::SharedContext

  def setup_terms_of_reference_database
    FactoryGirl.create(:terms_of_reference_version, :revision_major => 1, :revision_minor => 0)
    FactoryGirl.create(:terms_of_reference_version, :revision_major => 2, :revision_minor => 0)
  end

  def upload_document
    upload_file_path('first_upload_file.pdf')
  end

  def upload_file_path(filename)
    CapybaraRemote.upload_file_path(page,filename)
  end

  def upload_files_link
    page.find('.fileupload-buttonbar button.start')
  end
end
