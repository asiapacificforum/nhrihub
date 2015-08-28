class MediaAppearance < ActiveRecord::Base
  belongs_to :positivity_rating
  belongs_to :user
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  delegate :text, :rank, :to => :positivity_rating, :prefix => true, :allow_nil => true
  delegate :areas, :to => :description

  serialize :description, MediaAppearanceDescription

  def as_json(options={})
    super({:except => [:updated_at, :created_at],
           :methods=> [:date, :metrics, :has_link, :has_scanned_doc]})
  end

  def date
    created_at.to_date.to_s(:default)
  end

  def metrics
    MediaAppearanceMetrics.new(self)
  end

  def has_link
    !url.blank?
  end

  def has_scanned_doc
    !file_id.blank?
  end
end
