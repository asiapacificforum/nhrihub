require 'rspec/core/shared_context'

module ComplaintsCommunicationsSpecHelpers
  extend RSpec::Core::SharedContext
  def new_communication
    page.find('#new_communication')
  end

  def add_communication
    page.find('#add_communication').click
  end

  def close_datepicker
    page.execute_script("$('#communication_date').datepicker('hide')")
  end

  def communications
    page.all('#communications .communication')
  end

  def save_communication
    page.find("#save_communication").click
  end
end
