require 'rspec/core/shared_context'

module IndicatorMonitorSpecHelpers
  extend RSpec::Core::SharedContext
  def save_edit
    page.all('.monitor i.fa').detect{|el| el['id'] && el['id'].match(/monitor_editable\d*_edit_save/)}
  end

  def cancel_edit
    page.all('.monitor i.fa').detect{|el| el['id'] && el['id'].match(/monitor_editable\d*_edit_cancel/)}
  end

  def edit_monitor
    page.all('.monitor i.fa').select{|el| el['id'] && el['id'].match(/monitor_editable\d*_edit_start/)}
  end

  def delete_monitor
    page.all(".monitor #delete_monitor")
  end

  def monitor_description_error
    page.all("#new_monitor #description span.help-block")
  end

  def edit_monitor_description_error
    page.all(".monitor .description span.help-block")
  end

  def hover_over_info_icon
    page.execute_script("$('div.icon.monitor_info i').first().trigger('mouseenter')")
    sleep(0.2)
  end

  def author
    page.find('table#details td#author').text
  end

  def editor
    page.find('table#details td#editor').text
  end

  def last_edited
    page.find('table#details td#updated_on').text
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
