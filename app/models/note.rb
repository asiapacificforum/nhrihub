class Note < ActiveRecord::Base
  include ActionDispatch::Routing::PolymorphicRoutes
  include Rails.application.routes.url_helpers

  belongs_to :author, :class_name => "User", :foreign_key => :author_id
  belongs_to :editor, :class_name => "User", :foreign_key => :editor_id
  belongs_to :notable, :polymorphic => true

  default_scope ->{ order(:created_at => :desc) }

  def as_json(options = {})
    super(:methods => [:date, :author_name, :editor_name, :updated_on, :url])
  end

  def url
    notable.notable_url(id)
  end

  def updated_on
    created_at.localtime.to_date.to_s(:short)
  end

  def date
    created_at.localtime.to_date.to_s(:short)
  end

  def author_name
    # normally there should always be an author, but imported data may not have one
    author && author.first_last_name
  end

  def editor_name
    # normally there should always be an editor, but imported data may not have one
    editor && editor.first_last_name
  end
end
