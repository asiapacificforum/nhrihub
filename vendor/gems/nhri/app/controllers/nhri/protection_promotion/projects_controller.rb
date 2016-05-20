class Nhri::ProtectionPromotion::ProjectsController < ProjectsController
  def index
    @create_reminder_url = nhri_protection_promotion_project_reminders_path('en','id')
    @create_note_url     = nhri_protection_promotion_project_notes_path('en','id')
    @model = Nhri::ProtectionPromotion::Project
    super
  end
end
