require 'rspec/core/shared_context'

module IndicatorTextMonitorSpecHelpers
  extend RSpec::Core::SharedContext

  def edit_monitor
    page.all('#monitors .monitor i.fa-pencil-square-o')[0]
  end

  def number_of_text_monitors
    page.all('#monitors .monitor').count
  end

  def set_date_to(date_string)
    page.execute_script("var l = monitors.get('text_monitors').length; monitors.findAllComponents('textMonitor')[l-1].set('date', new Date(Date.parse('#{date_string}')))")
  end

  def monitor_description_error
    page.all("#new_monitor #description span.help-block")
  end

  def edit_save_monitor
    page.find('#monitor_editable2_edit_save')
  end

  def close_monitors_modal
    page.find('#text_monitors_modal button.close').click
    sleep(0.2) # css transition
  end

  def monitor_description
    page.all('.row.monitor .description')
  end

  def hover_over_info_icon
    page.execute_script("$('div.icon.monitor_info i').last().trigger('mouseenter')")
    sleep(0.2)
  end

end
