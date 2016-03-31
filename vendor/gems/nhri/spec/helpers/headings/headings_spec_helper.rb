require 'rspec/core/shared_context'

module HeadingsSpecHelper
  extend RSpec::Core::SharedContext

  def edit_first_offence
    page.all('.offence i.fa.fa-pencil-square-o.fa-lg')[0]
  end

  def delete_first_offence
    page.all('.offence i.fa-trash-o').first
  end

  def terminate_adding_offence
    page.find('#terminate_offence').click
  end

  def open_first_offences_dropdown
    page.all('.show_offences').first.click
    sleep(0.2) # css transition
  end

  def close_first_offences_dropdown
    page.all('.show_offences').first.click
    sleep(0.2) # css transition
  end

  def deselect_first_offence
    page.all('.deselect_offence')[0].click
  end

  def add_offence
    page.find('#add_offence')
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

  def edit_save_offence
    page.find('.offence i.fa.fa-check.fa-lg')
  end

  def setup_database
    3.times do |i|
      FactoryGirl.create(:heading, :with_offences, :title => "My really cool heading #{i}")
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
