require 'rspec/core/shared_context'

module IndicatorsSpecHelpers
  extend RSpec::Core::SharedContext

  def delete_indicator
    page.all('.indicator .delete_indicator')[0]
  end
end
