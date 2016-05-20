class Siu::ProjectsController < ProjectsController
  def index
    @create_reminder_url = siu_project_reminders_path('en','id')
    @create_note_url     = siu_project_notes_path('en','id')
    @model = Siu::Project
    super
  end
end
