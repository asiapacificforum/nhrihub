class ProjectAdminController < ApplicationController
  def show
    @project_document_filetypes = ProjectDocument.permitted_filetypes
    @filetype = Filetype.new
    @filesize = ProjectDocument.maximum_filesize
    @good_governance_project_type = ProjectType.new
    @human_rights_project_type = ProjectType.new
    @special_investigations_unit_project_type = ProjectType.new
    @strategic_plan_project_type = ProjectType.new
    good_governance_mandate = Mandate.find_by(:key => 'good_governance')
    @good_governance_project_types = good_governance_mandate ? good_governance_mandate.project_types.pluck(:name) : []
    human_rights_mandate = Mandate.find_by(:key => 'human_rights')
    @human_rights_project_types = human_rights_mandate ? human_rights_mandate.project_types.pluck(:name) : []
    special_investigations_unit_mandate = Mandate.find_by(:key => 'special_investigations_unit')
    @special_investigations_unit_project_types = special_investigations_unit_mandate ? special_investigations_unit_mandate.project_types.pluck(:name) : []
    strategic_plan_mandate = Mandate.find_by(:key => 'strategic_plan')
    @strategic_plan_project_types = strategic_plan_mandate ? strategic_plan_mandate.project_types.pluck(:name) : []
  end
end
