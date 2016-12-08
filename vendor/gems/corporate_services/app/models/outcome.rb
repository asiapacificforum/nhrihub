class Outcome < ActiveRecord::Base
  belongs_to :planned_result
  has_many :activities, :autosave => true, :dependent => :destroy

  default_scope ->{ order(:index) }

  # strip index if user has entered it
  before_create do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
    self.index = StrategicPlanIndexer.create(self)
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


  def <=>(other)
    self.index.split('.').map(&:to_i) <=> other.index.split('.').map(&:to_i)
  end

  def >=(other)
    [0,1].include?(self <=> other)
  end

  def decrement_index
    ar = index.split('.')
    new_suffix = ar.pop.to_i.pred.to_i
    ar << new_suffix
    new_index = ar.join('.')
    update_attribute(:index, ar.join('.'))
    activities.each{|o| o.decrement_index_prefix(new_index)}
  end

  def description_error
    nil
  end

  def increment_index_root
    ar = index.split('.')
    ar[0] = ar[0].to_i.succ.to_s
    new_index = ar.join('.')
    update_attribute(:index, new_index)
    activities.each{|a| a.increment_index_root}
  end

  def decrement_index_prefix(new_prefix)
    ar = index.split('.')
    new_index = [new_prefix,ar[2]].join('.')
    update_attribute(:index, new_index)
    activities.each{|o| o.decrement_index_prefix(new_index)}
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_planned_result_outcome_path(:en,planned_result_id,id)
  end

  def create_activity_url
    Rails.application.routes.url_helpers.corporate_services_outcome_activities_path(:en,id)
  end

  def indexed_description
    if description.blank?
      ""
    else
      [index, description].join(' ')
    end
  end

  def copy
    outcome = Outcome.new(attributes.slice("index", "description"))
    outcome.activities = activities.map(&:copy)
    outcome
  end

end
