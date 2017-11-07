require 'rspec/core/shared_context'

module NotesSpecCommonHelpers
  extend RSpec::Core::SharedContext

  def save_edit
    page.find('.note #edit_save')
  end

  def open_notes_modal
    notes_icon.click
    expect(page).to have_selector('#note .modal h4', :text => 'Notes', :visible => true)
  end

  def notes_icon
    page.all('.show_notes')[-1]
  end

  def close_notes_modal
    page.execute_script("$.support.transition=false")
    page.find('button.close').click()
  end

  def cancel_edit
    page.find('.note #edit_cancel')
  end

  def edit_note
    page.all('.note #edit_start')
  end

  def delete_note
    page.all(".note #delete_note")
  end

  def note_text_error
    page.all("#new_note #text span.help-block")
  end

  def edit_note_text_error
    page.all(".note .text span.help-block")
  end

  def hover_over_info_icon
    page.execute_script("$('div.icon.note_info i').first().trigger('mouseenter')")
    sleep(0.2)
  end

  def author
    page.find('table#details td#author').text
  end

  def editor
    page.find('table#details td#editor').text
  end

  def last_edited
    page.find('table#details td#updated_on').text
  end

  def show_notes
    sleep(0.3)
    page.find('.show_notes')
  end

  def add_note
    page.find('#add_note')
  end

  def save_note
    page.find('#save_note')
  end

  def note_text
    page.all('.row.note .text')
  end

  def note_date
    page.all('.row.note .date')
  end

  def note_info
    page.all('.row .note_info')
  end
end
