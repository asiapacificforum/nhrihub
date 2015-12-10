require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/media_admin_spec_helpers'

feature "configure description areas and subareas", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaAdminSpecHelpers

  before do
    create_default_areas
    resize_browser_window
    visit outreach_media_admin_path('en')
    sleep(0.1)
  end

  scenario 'default areas and subareas' do
    expect(page.all('.area .text').map(&:text)).to include "Human Rights"
    expect(page.all('.area .text').map(&:text)).to include "Good Governance"
    expect(page.all('.area .text').map(&:text)).to include "Special Investigations Unit"
    expect(page.all('.area .text').map(&:text)).to include "Corporate Services"
  end

  scenario 'add an area' do
    page.find('#area_name').set('What else')
    expect{ page.find('button#add_area').click; sleep(0.2)}.to change{ Area.count }.by 1
    expect(page.all('.area .text').map(&:text)).to include "What else"
  end

  scenario 'add an area with blank text' do
    expect{ page.find('button#add_area').click; sleep(0.2)}.not_to change{ Area.count }
    expect( page.find('#area_error') ).to have_text "Area can't be blank"
  end

  scenario 'add an area with whitespace text' do
    page.find('#area_name').set('    ')
    expect{ page.find('button#add_area').click; sleep(0.2)}.not_to change{ Area.count }
    expect( page.find('#area_error') ).to have_text "Area can't be blank"
  end

  scenario 'add an area with leading/trailing whitespace' do
    page.find('#area_name').set('     What else       ')
    expect{ page.find('button#add_area').click; sleep(0.2)}.to change{ Area.count }.by 1
    expect(page.all('.area .text').map(&:text)).to include "What else"
  end

  scenario 'blank area error message removed on keydown' do
    page.find('#area_name').set('    ')
    page.find('button#add_area').click
    sleep(0.2)
    expect( page.find('#area_error') ).to have_text "Area can't be blank"
    name_field = page.find("#area_name").native
    name_field.send_keys("!")
    expect( page ).not_to have_selector('#area_error')
  end

  scenario 'view subareas of an area' do
    open_accordion_for_area("Human Rights")
    expect(subareas).to include "Violation"
    expect(subareas).to include "Education activities"
    expect(subareas).to include "Office reports"
    expect(subareas).to include "Universal periodic review"
    expect(subareas).to include "CEDAW"
    expect(subareas).to include "CRC"
    expect(subareas).to include "CRPD"
  end

  scenario 'add a subarea' do
    open_accordion_for_area("Human Rights")
    page.find('#subarea_name').set('Another subarea')
    expect{ page.find('#add_subarea').click; sleep(0.2)}.to change{ Subarea.count }.by 1
    expect(subareas).to include "Another subarea"
  end

  scenario 'add a subarea with blank text' do
    open_accordion_for_area("Human Rights")
    expect{ page.find('#add_subarea').click; sleep(0.2)}.not_to change{ Subarea.count }
    expect( page.find('#subarea_error') ).to have_text "Subarea can't be blank"
  end

  scenario 'add a subarea with whitespace text' do
    open_accordion_for_area("Human Rights")
    page.find('#subarea_name').set('   ')
    expect{ page.find('#add_subarea').click; sleep(0.2)}.not_to change{ Subarea.count }
    expect( page.find('#subarea_error') ).to have_text "Subarea can't be blank"
  end

  scenario 'add a subarea with leading/trailing whitespace' do
    open_accordion_for_area("Human Rights")
    page.find('#subarea_name').set('    Another subarea   ')
    expect{ page.find('#add_subarea').click; sleep(0.2)}.to change{ Subarea.count }.by 1
    expect(subareas).to include "Another subarea"
  end

  scenario 'blank subarea error message removed on keydown' do
    open_accordion_for_area("Human Rights")
    page.find('#add_subarea').click
    sleep(0.2)
    expect( page.find('#subarea_error') ).to have_text "Subarea can't be blank"
    name_field = page.find("#subarea_name").native
    name_field.send_keys("!")
    expect( page ).not_to have_selector('#subarea_error', :visible => true)
  end

  scenario 'delete an area' do
    expect{click_delete_for("Human Rights"); sleep(0.4)}.to change{Area.count}.by(-1).
                                                         and change{Subarea.count}.by(-7)
    expect(page.all('.areas .area').length).to eq 3
  end

  scenario 'delete a subarea' do
    expect{click_delete_for("Human Rights", "Violation"); sleep(0.4)}.to change{Subarea.count}.by(-1)
    expect(subareas.length).to eq 6
  end
end
