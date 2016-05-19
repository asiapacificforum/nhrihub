require 'rails_helper'
require_relative '../helpers/good_governance_context_projects_spec_helpers'
require 'projects_behaviour'
require "new_project_file_management_behaviour"
require "existing_project_file_management_behaviour"

feature "projects index", :js => true do
  include GoodGovernanceContextProjectsSpecHelpers
  it_behaves_like "projects index"
end

feature "new project file management features", :js => true do
  include GoodGovernanceContextProjectsSpecHelpers
  it_behaves_like "new project file management"
end

feature "existing project file management features", :js => true do
  include GoodGovernanceContextProjectsSpecHelpers
  it_behaves_like "existing project file management"
end
