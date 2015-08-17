require 'rspec/core/shared_context'

module PlannedResultHelpers
  extend RSpec::Core::SharedContext

  def planned_results_descriptions
    page.all(".row.planned_result .col-md-2.description span")
  end

  def cancel_edit_planned_result
    page.all(".planned_result .description i").detect{|el| el['id'] && el['id'].match(/planned_result_editable\d*_edit_cancel/)}
  end

  def planned_result_save_icon
    page.find('.editable_container i#planned_result_editable1_edit_save')
  end

  def save_planned_result
    page.find("i#create_save")
  end

  def add_planned_result
    page.find(".new_planned_result")
  end
end
