class Note < ActiveRecord::Base
  belongs_to :activity
  belongs_to :author, :class_name => "User", :foreign_key => :author_id
  belongs_to :editor, :class_name => "User", :foreign_key => :editor_id

  default_scope ->{ order(:created_at => :desc) }

  def as_json(options = {})
    super(:methods => [:date, :author_name, :editor_name, :updated_on, :url])
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_activity_note_path(:en,activity_id,id)
  end

  def updated_on
    created_at.localtime.to_date.to_s(:short)
  end

  def date
    created_at.localtime.to_date.to_s(:short)
  end

  def author_name
    author.first_last_name
  end

  def editor_name
    editor.first_last_name
  end
end
