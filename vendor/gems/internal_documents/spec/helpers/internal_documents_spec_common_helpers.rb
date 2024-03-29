require 'rspec/core/shared_context'

module InternalDocumentsSpecCommonHelpers
  extend RSpec::Core::SharedContext
  def click_delete_document
    page.find('.template-download .delete').click
  end

  def click_delete_first_document
    page.all('.template-download .delete')[0].click
  end

  def attach_file(locator,file)
    page.attach_file("primary_file", file)
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
    wait_for_ajax
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

  def click_global_cancel_icon
    page.find(".fileupload-buttonbar .fa-ban").click
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
    expect{upload_files_link.click; sleep(0.5)}.to change{InternalDocument.count}.from(2).to(3) # starts with a primary and an archive file
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

  def confirm_delete_modal
    page.find('.modal#confirm-delete .modal-body')
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

  def set_upload_source_to_revision
    document_group_id = DocumentGroup.first.id
    page.execute_script("internal_document_uploader.findComponent('uploadDocuments').set('document_group_id',#{document_group_id})")
  end

  def set_upload_source_to_first_revision
    document_group_id = DocumentGroup.first.id
    page.execute_script("internal_document_uploader.findComponent('uploadDocuments').set('document_group_id',#{document_group_id})")
  end

  def set_upload_source_to_last_revision
    document_group_id = DocumentGroup.last.id
    page.execute_script("internal_document_uploader.findComponent('uploadDocuments').set('document_group_id',#{document_group_id})")
  end
end
