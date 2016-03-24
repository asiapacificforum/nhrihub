require 'rspec/core/shared_context'

module IndicatorFileMonitorSpecHelpers
  extend RSpec::Core::SharedContext

  def cancel_add
    page.find('#cancel_monitor').click
    sleep(0.1)
  end

  def set_date_to(date_string)
    page.execute_script("var l = monitors.get('text_monitors').length; monitors.findAllComponents('textMonitor')[l-1].set('date', new Date(Date.parse('#{date_string}')))")
  end

  def close_monitors_modal
    page.find('#text_monitors_modal button.close').click
    sleep(0.2) # css transition
  end

  def delete_monitor
    page.all(".monitor #delete_monitor")
  end

  def monitor_description_error
    page.all("#new_monitor #description span.help-block")
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

  def monitor_description
    page.all('.row.monitor .description')
  end

  def monitor_date
    page.all('.row.monitor .date')
  end

  def monitor_info
    page.all('.row .monitor_info')
  end
end
