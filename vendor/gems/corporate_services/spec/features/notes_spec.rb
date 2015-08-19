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
      expect(author).to eq "Norman Normal"
      expect(editor).to eq "Norman Normal"
      expect(last_edited).to eq "?"
      # add another note & confirm most-recent is first in list
    end

    xscenario "try to save note with blank text field" do
    end

    xscenario "try to save note with whitespace text field" do
    end
  end

  feature "when there are pre-existing notes" do
    before do
      setup_activity
      visit corporate_services_strategic_plan_path(:en, "current")
      open_accordion_for_strategic_priority_one
    end

    xscenario "add note" do
    end
  end

end


feature "actions on existing notes", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include StrategicPlanHelpers
  include SetupHelpers

  before do
    setup_activity
    setup_note
    visit corporate_services_strategic_plan_path(:en, "current")
    open_accordion_for_strategic_priority_one
  end

  xscenario "delete a note" do
  end

  xscenario "edit a note" do
    # do editing stuff
    note_info.click
    expect(last_edited).to eq "?"
    expect(editor).to eq "?"
  end

  xscenario "edit to blank text and cancel" do
  end

  xscenario "edit and cancel without making changes" do
  end
end
