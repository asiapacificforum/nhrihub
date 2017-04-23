require 'rspec/core/shared_context'

module IccSpecHelper
  extend RSpec::Core::SharedContext
  def upload_files_link
    page.find('.fileupload-buttonbar button.start')
  end

  def upload_document
    upload_file_path('first_upload_file.pdf')
  end

  def upload_file_path(filename)
    CapybaraRemote.upload_file_path(page,filename)
  end

  def delete_first_document
    page.all('.fa-trash-o').first.click
  end

  def click_the_archive_icon
    page.all('.template-download .fa-folder-o')[0].click
    sleep(0.2)
  end

  def click_the_first_download_icon
    page.all('.download').first.click
  end

  def click_the_download_icon
    page.find('.download').click
  end

  def archive_panel
    page.find('.collapse', :text => 'Archive')
  end
end
