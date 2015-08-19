require 'rspec/core/shared_context'

module NotesSpecHelpers
  extend RSpec::Core::SharedContext
  def save_edit
    page.all('.note i.fa').detect{|el| el['id'] && el['id'].match(/note_editable\d*_edit_save/)}
  end

  def cancel_edit
    page.all('.note i.fa').detect{|el| el['id'] && el['id'].match(/note_editable\d*_edit_cancel/)}
  end

  def edit_note
    page.all('.note i.fa').select{|el| el['id'] && el['id'].match(/note_editable\d*_edit_start/)}
  end

  def delete_note
    page.all(".note #delete_note")
  end

  def setup_note
    FactoryGirl.create(:note, :activity_id => Activity.first.id)
  end

  def note_text_error
    page.all("#new_note #text span.help-block")
  end

  def hover_over_info_icon
    page.execute_script("$('div.icon.note_info i').last().trigger('mouseenter')")
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
    page.find('i.show_notes')
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
