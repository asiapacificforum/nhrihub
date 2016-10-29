require 'rspec/core/shared_context'

module IndicatorNumericMonitorSpecHelpers
  extend RSpec::Core::SharedContext

  def monitor_description_error
    page.all("#new_monitor #description span.help-block")
  end

  def number_of_numeric_monitors
    page.all('#monitors .monitor').count
  end

  def set_date_to(date_string)
    page.execute_script("var l = monitors.get('numeric_monitors').length; monitors.findAllComponents('numericMonitor')[l-1].set('date', new Date(Date.parse('#{date_string}')))")
  end

  def monitor_value_error
    page.all("#new_monitor #value span.help-block")
  end

  def monitor_value
    page.all('.row.monitor .value')
  end

  def close_monitors_modal
    page.find('#numeric_monitors_modal button.close').click
    sleep(0.2) # css transition
  end

  def hover_over_info_icon
    page.execute_script("$('div.icon.monitor_info i').last().trigger('mouseenter')")
    sleep(0.2)
  end
end
