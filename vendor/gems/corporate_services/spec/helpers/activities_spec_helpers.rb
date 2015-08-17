require 'rspec/core/shared_context'

module ActivitiesSpecHelpers
  extend RSpec::Core::SharedContext

  def first_activity_description_field
    page.all(activity_selector + ".description div.no_edit span:nth-of-type(1)")[0]
  end

  def activity_edit_cancel
    page.all(activity_selector+" i").detect{|el| el['id'].match(/activity_editable\d*_edit_cancel/)}
  end

  def activity_selector
    ".table#planned_results .row.planned_result .row.outcome .row.activity "
  end

  def activity_description_field
    page.all(activity_selector + ".description textarea").select{|i| i['id'] && i['id'].match(/activity_\d_description/)}
  end

  def activity_performance_indicator_field
    page.all(activity_selector + ".performance_indicator textarea").select{|i| i['id'] && i['id'].match(/activity_\d_performance_indicator/)}
  end

  def activity_progress_field
    page.all(activity_selector + ".activity_progress textarea").select{|i| i['id'] && i['id'].match(/activity_\d_progress/)}
  end

  def activity_target_field
    page.all(activity_selector + ".target textarea").select{|i| i['id'] && i['id'].match(/activity_\d_target/)}
  end

  def activity_save_icon
    page.all(activity_selector + ".description .edit.in i.fa-check").detect{|i| i['id'] && i['id'].match(/activity_editable\d+_edit_save/)}
  end

  def save_activity
    page.find("i#create_save")
  end

  def add_activity
    page.find(".new_activity")
  end
end
