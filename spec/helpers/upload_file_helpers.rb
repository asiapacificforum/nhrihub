require 'rspec/core/shared_context'

module UploadFileHelpers
  extend RSpec::Core::SharedContext
  #TODO this method needs to be made generic and used throughout the app,
  #and all the many instances removed
  def attach_file(locator,file,index = nil)
    page.attach_file("primary_file", upload_document, :visible => false)
    if !index # when it's first time, we pass a non-nil argument like :first_time
      if page.evaluate_script('navigator.userAgent').match(/phantomjs/i)
        # because the change event is not triggered when the same file is uploaded again,
        # so must trigger it manually in a test scenario (or else use many different files)
        page.execute_script("$('#primary_fileinput').trigger('change')")
      end
    end
  end

  #TODO this method needs to be made generic and used throughout the app,
  #and all the many instances removed
  def add_a_second_file
    page.attach_file("primary_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("a second file")
    page.find('#internal_document_revision').set("3.3")
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
    expect(page).to have_css(".files .template-download", :count => 2)
  end

  def upload_file_path(filename)
    CapybaraRemote.upload_file_path(page,filename)
  end

  def upload_document
    upload_file_path('first_upload_file.pdf')
  end

  def big_upload_document
    upload_file_path('big_upload_file.pdf')
  end

  def upload_image
    upload_file_path('first_upload_image_file.png')
  end
end
