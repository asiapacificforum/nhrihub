require 'rspec/core/shared_context'

module InternalDocumentsSpecHelpers
  extend RSpec::Core::SharedContext
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

  def populate_database
    current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
    doc = FactoryGirl.create(:internal_document,
                             :revision => first_doc_rev.to_s,
                             :title => Faker::Lorem.words(4).join(' '),
                             :original_filename => Faker::Lorem.words(3).join('_')+'.doc')
    dgid = doc.document_group_id
    4.times do |i|
      current_doc_rev -= 0.1
      current_doc_rev = current_doc_rev.round(1)
      FactoryGirl.create(:internal_document,
                         :document_group_id => dgid,
                         :revision => current_doc_rev.to_s,
                         :title => Faker::Lorem.words(4).join(' '),
                         :original_filename => Faker::Lorem.words(3).join('_')+'.doc')
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

  def click_the_archive_file_details_icon
    page.all('.details').last.click
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
    page.find('.template-download .fa-folder-o').click
    sleep(0.2)
  end

  def create_a_document_in_the_same_group(**options)
    revision_major, revision_minor = options.delete(:revision).to_s.split('.') if options && options[:revision]
    group_id = @doc.document_group_id
    options = options.merge({ :revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9), :document_group_id => group_id})
    @archive_doc = FactoryGirl.create(:internal_document, options)
  end

  def click_the_download_icon
    page.find('.download').click
  end

  def click_the_edit_icon(context)
    context.all('.fa-pencil-square-o')[0].click
    #context.find('.fa-pencil-square-o').click
    sleep(0.1)
  end

  def create_a_document(**options)
    revision_major, revision_minor = options.delete(:revision).split('.') if options && options[:revision]
    options = options.merge({:revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9)})
    FactoryGirl.create(:internal_document, options)
  end

  def add_document_link
    page.find('.fileinput-button')
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
