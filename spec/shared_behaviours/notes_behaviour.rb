RSpec.shared_examples "notes" do
  feature "notes behaviour" do
    scenario "add note" do
      expect(notes_icon['data-count']).to eq "2"
      add_note.click
      expect(page).to have_selector("#new_note #note_text")
      fill_in(:note_text, :with => "nota bene")
      expect{save_note.click; wait_for_ajax}.to change{ Note.count }.from(2).to(3).
                                            and change{ note_text.count }.from(2).to(3)
      expect(note_text.first.text).to eq "nota bene"
      expect(note_date.first.text).to eq Date.today.to_s(:short)
      hover_over_info_icon
      expect(author).to eq User.first.first_last_name
      expect(editor).to eq User.first.first_last_name
      expect(last_edited).to eq Date.today.to_s(:short)
      close_notes_modal
      expect(notes_icon['data-count']).to eq "3"
    end

    scenario "start adding a note, close modal panel, and then restart" do
      add_note.click
      expect(page).to have_selector("#new_note #note_text")
      fill_in(:note_text, :with => "nota bene")
      close_notes_modal
      open_notes_modal
      expect(page).not_to have_selector("#new_note #note_text")
    end

    scenario "try to save note with blank text field" do
      add_note.click
      # skip setting the text
      save_note.click
      wait_for_ajax
      expect(Note.count).to eq 2
      expect(note_text_error.first.text).to eq "Text cannot be blank"
    end

    scenario "try to save note with whitespace text field" do
      add_note.click
      fill_in(:note_text, :with => " ")
      save_note.click
      wait_for_ajax
      expect(Note.count).to eq 2
      expect(note_text_error.first.text).to eq "Text cannot be blank"
    end

    scenario "notes are rendered in reverse chronological order" do
      expect(page).to have_selector("h4", :text => 'Notes')
      expect(note_date.map(&:text)).to eq [3.days.ago.localtime.to_date.to_s(:short), 4.days.ago.localtime.to_date.to_s(:short)]
    end

    scenario "delete a note" do
      expect{ delete_note.first.click; confirm_deletion; wait_for_ajax }.to change{Note.count}.from(2).to(1)
      expect(notes_icon['data-count']).to eq "1"
    end

    scenario "edit a note" do
      edit_note.first.click
      fill_in('note_text', :with => "carpe diem")
      expect{ save_edit.click; wait_for_ajax }.to change{Note.first.text}.to("carpe diem")
      expect(page).to have_selector('#notes .note .text .no_edit span', :text => 'carpe diem')
    end

    scenario "edit to blank text and cancel" do
      original_text = note_text.first.text
      edit_note.first.click
      fill_in('note_text', :with => " ")
      save_edit.click
      wait_for_ajax
      expect(edit_note_text_error.first.text).to eq "Text cannot be blank"
      cancel_edit.click
      expect(note_text.first.text).to eq original_text
      edit_note.first.click
      expect(page).not_to have_selector(".note .text.has-error")
    end

    scenario "edit and cancel without making changes" do
      original_text = note_text.first.text
      edit_note.first.click
      cancel_edit.click
      expect(note_text.first.text).to eq original_text
    end

    scenario "edit and close notes modal without making changes" do
      original_text = note_text.first.text
      edit_note.first.click
      expect(note_text.first.text).to eq original_text
      close_notes_modal
      open_notes_modal
      expect(page).not_to have_selector("#note_text")
    end
  end
end
