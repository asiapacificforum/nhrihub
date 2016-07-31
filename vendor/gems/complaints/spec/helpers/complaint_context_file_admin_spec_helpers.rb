require 'rspec/core/shared_context'

module ComplaintContextFileAdminSpecHelpers
  extend RSpec::Core::SharedContext

  def model
    ComplaintDocument
  end

  def filesize_context
    page.find('#complaint_document_filesize')
  end

  def filesize_selector
    '#complaint_document_filesize'
  end

  def filetypes_context
    #filetypes_top = page.evaluate_script("$('#complaint_document_filetypes').offset().top")
    #page.execute_script("scrollTo(0,#{filetypes_top}-60)")
    page.find('#complaint_document_filetypes')
  end

  def filetypes_selector
    '#complaint_document_filetypes'
  end

  def admin_page
    complaint_admin_path('en')
  end
end
