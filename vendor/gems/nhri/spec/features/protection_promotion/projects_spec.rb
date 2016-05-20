require 'rails_helper'
require_relative './../../helpers/protection_promotion/nhri_context_projects_spec_helpers'
#require 'login_helpers'
require 'projects_behaviour'
require "new_project_file_management_behaviour"
require "existing_project_file_management_behaviour"

feature "projects index", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NhriContextProjectsSpecHelpers
  it_behaves_like "projects index"
end

feature "new project file management features", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NhriContextProjectsSpecHelpers
  it_behaves_like "new project file management"
end

feature "existing project file management features", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NhriContextProjectsSpecHelpers
  it_behaves_like "existing project file management"
end
