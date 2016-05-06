require 'rspec/core/shared_context'

module HeadingsSpecHelper
  extend RSpec::Core::SharedContext

  def edit_first_attribute
    page.all('.attribute i.fa.fa-pencil-square-o.fa-lg')[0]
  end

  def delete_first_attribute
    page.all('.attribute i.fa-trash-o').first
  end

  def terminate_adding_attribute
    page.find('#terminate_attribute').click
  end

  def open_first_attributes_dropdown
    page.all('.show_attributes').first.click
    sleep(0.2) # css transition
  end

  def close_first_attributes_dropdown
    page.all('.show_attributes').first.click
    sleep(0.2) # css transition
  end

  def deselect_first_attribute
    page.all('.deselect_attribute')[0].click
  end

  def add_attribute
    page.find('#add_attribute')
  end

  def cancel_add
    page.find('#heading_cancel')
  end

  def add_heading
    page.find('#add_heading')
  end

  def save_heading
    page.find('#heading_save')
  end

  def edit_save
    page.find('i.fa.fa-check.fa-lg')
  end

  def edit_save_attribute
    page.find('.attribute i.fa.fa-check.fa-lg')
  end

  def setup_database
    3.times do |i|
      FactoryGirl.create(:heading, :with_three_human_rights_attributes, :title => "My really cool heading #{i}")
    end
  end

  def delete_heading
    page.all('.delete_heading')[0]
  end

  def edit_first_heading
    page.all('i.fa.fa-pencil-square-o.fa-lg')[0]
  end

  def edit_second_heading
    page.all('i.fa.fa-pencil-square-o.fa-lg')[1]
  end

  def edit_cancel
    page.find('i.fa.fa-remove.fa-lg')
  end
end
