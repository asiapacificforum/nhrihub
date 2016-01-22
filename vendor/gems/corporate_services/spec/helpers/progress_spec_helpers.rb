require 'rspec/core/shared_context'

module ProgressSpecHelpers
  extend RSpec::Core::SharedContext
  def progress_selector
    performance_indicator_selector + ".performance_indicator_progress div"
  end
end
