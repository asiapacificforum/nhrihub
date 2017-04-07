require 'rspec/core/shared_context'

module ProjectsContextPerformanceIndicatorSpecHelpers
  extend RSpec::Core::SharedContext
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IERemoteDetector
  include NavigationHelpers
  include ProjectsSpecHelpers

  before do
    @model = Project
    @association = ProjectPerformanceIndicator
  end

  def edit_first_item
    edit_first_project.click
  end

  def add_new_item
    add_project.click
  end
end
