require 'rspec/core/shared_context'

module StrategicPrioritySpecHelpers
  extend RSpec::Core::SharedContext

  def strategic_priority_cancel_edit_icon
    page.find(:xpath, ".//i[@id='strategic_priority_editable1_edit_cancel']")
  end

  def strategic_priority_edit_save_icon
    page.find(:xpath, ".//i[@id='strategic_priority_editable1_edit_save']")
  end

  def second_strategic_priority_edit_icon
    page.all(:xpath, ".//i").select{|el| el['id'] && el['id']=~/strategic_priority_editable\d+_edit_start/}[1]
  end

  def edit_strategic_priority
    strategic_priority_edit_icon
  end

  def strategic_priority_edit_icon
    page.all('.strategic_priority #edit_start').first
  end

  def second_strategic_priority_delete_icon
    page.all('i#delete')[1]
  end

  def strategic_priority_delete_icon
    page.find('i#delete')
  end

  def add_priority_button
    page.find('#add_strategic_priority')
  end

  def click_anywhere
    page.find('body').click
  end

  def add_strategic_priority(attrs)
    add_priority_button.click
    sleep(0.1)
    within "form#new_strategic_priority" do
      select attrs[:priority_level].to_s, :from => 'strategic_priority_priority_level' if attrs[:priority_level]
      fill_in "strategic_priority_description", :with => attrs[:description] if attrs[:description]
      page.find('#edit-save').click
      wait_for_ajax
    end
  end
end
