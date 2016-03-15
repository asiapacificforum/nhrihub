require 'rspec/core/shared_context'

module HeadingsSpecHelper
  extend RSpec::Core::SharedContext

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

  def setup_database
    3.times do |i|
      FactoryGirl.create(:heading, :title => "My really cool heading #{i}")
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
