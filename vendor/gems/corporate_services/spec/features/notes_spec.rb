require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/strategic_plan_helpers'
require_relative '../helpers/setup_helpers'
require_relative '../helpers/notes_spec_helpers'


feature "populate activity notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include SetupHelpers
  include NotesSpecHelpers

  feature "when there were none before" do
    before do
      setup_activity
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
    end

    scenario "add note" do
      show_notes.click
      expect(page).to have_selector("h4", :text => 'Notes')
      add_note.click
      fill_in(:note_text, :with => "nota bene")
      save_note.click
      sleep(0.2)
      expect(Note.count).to eq 1
      expect(note_text.first.text).to eq "nota bene"
      expect(note_date.first.text).to eq Date.today.to_s(:short)
      hover_over_info_icon
      expect(author).to eq User.first.first_last_name
      expect(editor).to eq User.first.first_last_name
      expect(last_edited).to eq Date.today.to_s(:short)
    end

    scenario "try to save note with blank text field" do
      show_notes.click
      expect(page).to have_selector("h4", :text => 'Notes')
      add_note.click
      # skip setting the text
      save_note.click
      sleep(0.2)
      expect(Note.count).to eq 0
      expect(note_text_error.first.text).to eq "Text cannot be blank"
    end

    scenario "try to save note with whitespace text field" do
      show_notes.click
      expect(page).to have_selector("h4", :text => 'Notes')
      add_note.click
      fill_in(:note_text, :with => " ")
      save_note.click
      sleep(0.2)
      expect(Note.count).to eq 0
      expect(note_text_error.first.text).to eq "Text cannot be blank"
    end
  end

  feature "show notes" do
    before do
      setup_activity
      @note1 = FactoryGirl.create(:note, :notable_type => "Activity", :created_at => 3.days.ago, :notable_id => Activity.first.id)
      @note2 = FactoryGirl.create(:note, :notable_type => "Activity", :created_at => 4.days.ago, :notable_id => Activity.first.id)
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
    end

    scenario "rendered in reverse chronological order" do
      show_notes.click
      expect(page).to have_selector("h4", :text => 'Notes')
      expect(note_date.map(&:text)).to eq [3.days.ago.localtime.to_date.to_s(:short), 4.days.ago.localtime.to_date.to_s(:short)]
    end
  end
end


feature "actions on existing notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include SetupHelpers
  include NotesSpecHelpers

  before do
    setup_activity
    setup_note
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
    show_notes.click
    expect(page).to have_selector("h4", :text => 'Notes')
  end

  scenario "delete a note" do
    expect{ delete_note.first.click; sleep(0.2) }.to change{Note.count}.from(1).to(0)
  end

  scenario "edit a note" do
    edit_note.first.click
    fill_in('note_text', :with => "carpe diem")
    expect{ save_edit.click; sleep(0.2) }.to change{Note.first.text}.to("carpe diem")
  end

  scenario "edit to blank text and cancel" do
    original_text = note_text.first.text
    edit_note.first.click
    fill_in('note_text', :with => " ")
    cancel_edit.click
    expect(note_text.first.text).to eq original_text
  end

  scenario "edit and cancel without making changes" do
    original_text = note_text.first.text
    edit_note.first.click
    cancel_edit.click
    expect(note_text.first.text).to eq original_text
  end
end
