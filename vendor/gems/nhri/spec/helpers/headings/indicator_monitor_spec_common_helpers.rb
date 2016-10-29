require 'rspec/core/shared_context'

module IndicatorMonitorSpecCommonHelpers
  extend RSpec::Core::SharedContext

  def show_monitors
    sleep(0.3)
    page.find('.show_monitors')
  end

  def monitor_icon_count
    # you'd think that $('.show_monitors.counter').data('count') would work, but it gets fixed at the page-load value
    page.evaluate_script("parseInt($('.show_monitors').attr('data-count'))")
  end

  def delete_monitor
    page.all("#delete_monitor").first
  end

  def cancel_add
    page.find('#cancel_monitor').click
    sleep(0.1)
  end

  def monitor_info
    page.all('.row .monitor_info')
  end

  def monitor_date
    page.all('.row.monitor .date')
  end

  def save_monitor
    page.find('#save_monitor')
  end

  def add_monitor
    page.find('#add_monitor')
  end

  def author
    page.find('table#details td#author').text
  end
end

