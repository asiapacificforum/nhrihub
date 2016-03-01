require 'rspec/core/shared_context'

module AdvisoryCouncilMinutesSetupHelper
  extend RSpec::Core::SharedContext

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
