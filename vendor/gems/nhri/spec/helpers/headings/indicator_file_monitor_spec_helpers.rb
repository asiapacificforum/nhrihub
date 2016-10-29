require 'rspec/core/shared_context'

module IndicatorFileMonitorSpecHelpers
  extend RSpec::Core::SharedContext

  def number_of_file_monitors
    page.all('#monitors .monitor').count
  end

  def deselect_file
    page.find('#deselect_file').click
  end

  def file_size
    page.find('#filesize').text
  end

  def click_the_download_icon
    page.find('.download').click
  end

  def close_monitors_modal
    page.find('#file_monitor_modal button.close').click
    sleep(0.2) # css transition
  end

  def monitor_description_error
    page.all("#new_monitor #description span.help-block")
  end

  def hover_over_info_icon
    page.execute_script("$('i#show_details').trigger('mouseenter')")
    sleep(0.2)
  end

  def author
    page.find('table#details td#author').text
  end

  def monitor_description
    page.all('.row.monitor .description')
  end

end
