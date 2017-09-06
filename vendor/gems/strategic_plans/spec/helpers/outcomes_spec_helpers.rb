require 'rspec/core/shared_context'

module OutcomesSpecHelpers
  extend RSpec::Core::SharedContext
  def click_delete_outcome
    page.find(".row.planned_result .row.outcome .col-md-2.description span.delete_icon").click
  end

  def outcome_edit_cancel
    page.find("#edit_cancel")
  end

  def outcome_descriptions
    page.all(".row.planned_result .row.outcome .col-md-2.description span")
  end

  def edit_outcome
    outcome_descriptions.first
  end

  def outcome_description_field
    page.all(".row.outcome .edit.in textarea").detect{|el| el['id'].match(/outcome_\d*_description/)}
  end

  def outcome_save_icon
    page.find('#edit_save')
  end

  def save_outcome
    page.find("i#create_save")
  end

  def add_outcome
    page.find(".new_outcome")
  end
end
