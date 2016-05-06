require 'rspec/core/shared_context'

module InternalDocumentsSpecCommonHelpers
  extend RSpec::Core::SharedContext

  # it's a test spec workaround, this method can be called multiple times
  # whereas page.attach_file cannot
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

  def upload_files_link
    page.find('.fileupload-buttonbar button.start')
  end

  def setup_accreditation_required_groups
    titles = ["Statement of Compliance", "Enabling Legislation", "Organization Chart", "Annual Report", "Budget"]
    titles.each do |title|
      AccreditationDocumentGroup.create(:title => title)
    end
  end

  def click_edit_save_icon(context)
    context.find('.fa-check').click
    sleep(0.1)
  end

  def click_edit_cancel_icon(context)
    context.find('.fa-remove').click
    sleep(0.1)
  end

  def upload_single_file_link_click(which)
    sleep(0.1) # ajax response and javascript transitions
    links = page.all('.template-upload .fa-cloud-upload')
    links[0].click()
    sleep(0.2) # ajax post of file
  end

  def click_cancel_icon
    page.find(".template-upload .fa-ban").click
  end

  def archive_panel
    page.find('.collapse', :text => 'Archive')
  end

  def primary_panel
    page.find('.template-download .panel-heading')
  end

  def click_the_archive_delete_icon
    page.find('.collapse i.fa-trash-o').click
  end

  def add_a_second_file
    page.attach_file("primary_file", upload_document, :visible => false)
    page.find("#internal_document_title").set("a second file")
    page.find('#internal_document_revision').set("3.3")
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(1).to(2)
    expect(page).to have_css(".files .template-download", :count => 2)
  end

  def click_the_archive_icon
    page.all('.template-download .fa-folder-o')[0].click
    sleep(0.2)
  end

  def click_the_download_icon
    page.find('.download').click
  end

  def click_the_edit_icon(context)
    context.all('.fa-pencil-square-o')[0].click
    sleep(0.1)
  end

  def upload_replace_files_link
    page.find('.template-upload .start .fa-cloud-upload')
  end

  def upload_files_link
    page.find('.fileupload-buttonbar button.start')
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
