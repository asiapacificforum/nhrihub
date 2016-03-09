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
    FactoryGirl.create(:heading, :title => "My really cool heading")
  end

  def delete_heading
    page.find('.delete_heading')
  end

  def edit_heading
    page.find('i.fa.fa-pencil-square-o.fa-lg')
  end

  def edit_cancel
    page.find('i.fa.fa-remove.fa-lg')
  end
end
