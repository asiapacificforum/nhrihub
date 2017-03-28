require 'rspec/core/shared_context'

module MediaIssuesCommonHelpers
  extend RSpec::Core::SharedContext

  def add_save
    page.find('#save_add').click
    wait_for_ajax
  end

  def edit_article
    page.all('.fa-pencil-square-o')
  end

  def add_article_button
    page.find('.add_article')
  end

  def edit_save
    page.find('#_edit_save').click
    wait_for_ajax
  end

  def chars_remaining
    page.find('.chars_remaining').text
  end

  def areas
    page.all("#{single_item_selector} .expanded_info .description .area .name").map(&:text)
  end

  def subareas
    page.all("#{single_item_selector} .expanded_info .description .subareas .subarea").map(&:text)
  end

  def add_cancel
    page.find("#{single_item_selector} #cancel_add").click
  end

  def edit_cancel
    page.find('#_edit_cancel').click
  end

  def click_delete_article
    page.find("#{single_item_selector} .delete_icon_sm").click
  end

  def click_note_icon
    page.find("#{single_item_selector} .basic_info .actions .show_notes").click
    sleep(0.4)
  end

  def click_add_note
    page.find('#add_note').click
    sleep(0.4)
  end

  def save_note
    page.find('#save_note').click
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

  def clear_file_attachment
    page.execute_script("scrollTo(0,0)")
    page.find("#deselect_file").click
  end

  def click_the_download_icon
    page.find("#{single_item_selector} .actions .fa-cloud-download").click
  end

  def click_the_link_icon
    page.find("#{single_item_selector} .actions .fa-globe").click
  end

  def select_performance_indicators
    sleep(0.1)
    page.find('.performance_indicator_select>a')
  end

  def select_first_planned_result
    sleep(0.1)
    page.all(".dropdown-submenu.planned_result").first.hover
  end

  def select_first_outcome
    sleep(0.1)
    page.all(".dropdown-submenu.outcome").first.hover
  end

  def select_first_activity
    sleep(0.1)
    page.all(".dropdown-submenu.activity").first.hover
  end

  def select_first_performance_indicator
    sleep(0.1)
    page.all("li.performance_indicator").first.click
  end

end
