require 'rspec/core/shared_context'

module NotesSpecHelpers
  extend RSpec::Core::SharedContext

  def hover_over_info_icon
    page.execute_script("$('div.icon.note_info').last().trigger('mouseenter')")
    sleep(0.2)
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
