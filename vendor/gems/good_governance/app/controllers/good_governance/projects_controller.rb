class GoodGovernance::ProjectsController < ProjectsController
  def index
    @create_reminder_url = good_governance_project_reminders_path('en','id')
    @create_note_url     = good_governance_project_notes_path('en','id')
    @model = GoodGovernance::Project
    super
  end
end
