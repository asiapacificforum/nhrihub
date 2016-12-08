class Outcome < ActiveRecord::Base
  include StrategicPlanIndex
  belongs_to :planned_result
  has_many :activities, :autosave => true, :dependent => :destroy

  default_scope ->{ order(:index) }

  # strip index if user has entered it
  before_create do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
    self.index = create_index
  end

  def as_json(options={})
    super(:except => [:updated_at, :created_at],
          :methods => [:indexed_description, :description, :id, :url, :create_activity_url, :activities, :description_error])
  end

  after_destroy do |outcome|
    lower_indexes = Outcome.
                      where(:planned_result_id => outcome.planned_result_id).
                      select{|o| o >= self}
    lower_indexes.each{|o| o.decrement_index }
  end

  def index_descendant
    activities
  end

  def index_parent
    planned_result
  end

  def description_error
    nil
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_planned_result_outcome_path(:en,planned_result_id,id)
  end

  def create_activity_url
    Rails.application.routes.url_helpers.corporate_services_outcome_activities_path(:en,id)
  end

  def copy
    outcome = Outcome.new(attributes.slice("index", "description"))
    outcome.activities = activities.map(&:copy)
    outcome
  end

end
