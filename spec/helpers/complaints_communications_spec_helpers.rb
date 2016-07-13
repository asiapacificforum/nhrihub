require 'rspec/core/shared_context'

module ComplaintsCommunicationsSpecHelpers
  extend RSpec::Core::SharedContext
  def new_communication
    page.find('#new_communication')
  end

  def add_communication
    page.find('#add_communication').click
  end

  def set_datepicker(id,date)
    page.execute_script %Q{ $('##{id}').trigger('focus') } # trigger datepicker
    page.execute_script %Q{ $('##{id}').datepicker('setDate','#{date}') }
    page.execute_script %Q{ $('##{id}').datepicker('hide') } # trigger the onClose handler
  end

  def communications
    page.all('#communications .communication')
  end

  def save_communication
    page.find("#save_communication").click
    wait_for_ajax
  end

  def delete_communication
    page.all('#communications .communication .delete .delete_icon')[0].click
    wait_for_ajax
  end

  def click_the_note_icon
    page.find('.note .note_icon').click
  end

  def local_offset
    (DateTime.now.utc_offset/60/60).to_s
  end

  def remove_first_document
    page.all('.document .remove')[0].click
  end

  def edit_communication
    expect(page).to have_selector (".communication .fa-pencil-square-o")
    page.all(".communication .fa-pencil-square-o")[0].click
  end

  def edit_save
    page.all(".communication .fa-check")[0].click
  end

  def dismiss_the_note_modal
    page.find('#single_note button.close').click
  end
end
