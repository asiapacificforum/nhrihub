require 'rspec/core/shared_context'

module RemindersSpecCommonHelpers
  extend RSpec::Core::SharedContext

  def recipients
    page.find("#new_reminder #recipients")
  end

  def reminder_type
    page.find("#new_reminder #reminder_type")
  end

  def text_error_message
    text_error.text
  end

  def text_error
    page.find("#new_reminder #text.has-error .help-block")
  end

  def recipients_error_message
    recipients_error.text
  end

  def recipients_error
    page.find("#new_reminder #recipients.has-error .help-block")
  end

  def reminder_error_message
    reminder_error.text
  end

  def reminder_error
    page.find("#new_reminder #reminder_type.has-error .help-block")
  end

  def edit_reminder_icon
    page.find(:xpath, ".//i[@id='reminder_editable1_edit_start']")
  end

  def edit_reminder_save_icon
    page.find(:xpath, ".//i[@id='reminder_editable1_edit_save']")
  end

  def save_reminder
    page.find("i#save_reminder")
  end

  def edit_reminder_cancel
    page.all("#reminders .reminder i").detect{|el| el['id'].match(/reminder_editable\d*_edit_cancel/)}
  end

  def cancel_reminder
    page.find("i#cancel_reminder")
  end

  def reminder_delete_icon
    page.find("i#delete_reminder")
  end

  def new_reminder_button
    page.find('i#add_reminder')
  end
end
