require 'rspec/core/shared_context'

module IndicatorNumericMonitorSpecHelpers
  extend RSpec::Core::SharedContext

  def monitor_icon_count
    # you'd think that $('.show_monitors.counter').data('count') would work, but it gets fixed at the page-load value
    page.evaluate_script("parseInt($('.show_monitors.counter').attr('data-count'))")
  end

  def monitor_description_error
    page.all("#new_monitor #description span.help-block")
  end

  def number_of_numeric_monitors
    page.all('#monitors .monitor').count
  end

  def cancel_add
    page.find('#cancel_monitor').click
    sleep(0.1)
  end

  def set_date_to(date_string)
    page.execute_script("var l = monitors.get('numeric_monitors').length; monitors.findAllComponents('numericMonitor')[l-1].set('date', new Date(Date.parse('#{date_string}')))")
  end

  def close_monitors_modal
    page.find('#numeric_monitors_modal button.close').click
    sleep(0.2) # css transition
  end

  def delete_monitor
    page.all(".monitor #delete_monitor")
  end

  def monitor_value_error
    page.all("#new_monitor #value span.help-block")
  end

  def hover_over_info_icon
    page.execute_script("$('div.icon.monitor_info i').last().trigger('mouseenter')")
    sleep(0.2)
  end

  def author
    page.find('table#details td#author').text
  end

  def show_monitors
    sleep(0.3)
    page.find('i.show_monitors')
  end

  def add_monitor
    page.find('#add_monitor')
  end

  def save_monitor
    page.find('#save_monitor')
  end

  def monitor_value
    page.all('.row.monitor .value')
  end

  def monitor_date
    page.all('.row.monitor .date')
  end

  def monitor_info
    page.all('.row .monitor_info')
  end
end
