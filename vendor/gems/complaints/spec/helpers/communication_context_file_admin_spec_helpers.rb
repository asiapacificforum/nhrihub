require 'rspec/core/shared_context'

module CommunicationContextFileAdminSpecHelpers
  extend RSpec::Core::SharedContext

  def model
    CommunicationDocument
  end

  def filesize_selector
    '#communication_filesize'
  end

  def filesize_context
    page.find('#communication_filesize')
  end

  def filetypes_context
    #filetypes_top = page.evaluate_script("$('#communication_document_filetypes').offset().top")
    #page.execute_script("scrollTo(0,#{filetypes_top}-40)")
    page.find('#communication_document_filetypes')
  end

  def filetypes_selector
    '#communication_document_filetypes'
  end

  def admin_page
    complaint_admin_path('en')
  end
end
