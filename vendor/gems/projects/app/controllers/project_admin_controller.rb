class ProjectAdminController < ApplicationController
  def show
    @project_document_filetypes = ProjectDocument.permitted_filetypes
    @filetype = Filetype.new
    @filesize = ProjectDocument.maximum_filesize
    @good_governance_project_type = ProjectType.new
    @human_rights_project_type = ProjectType.new
    @special_investigations_unit_project_type = ProjectType.new
    @good_governance_project_types = Mandate.find_by(:key => 'good_governance').project_types.all.map(&:name)
    @human_rights_project_types = Mandate.find_by(:key => 'human_rights').project_types.all.map(&:name)
    @special_investigations_unit_project_types = Mandate.find_by(:key => 'special_investigations_unit').project_types.all.map(&:name)
  end
end
