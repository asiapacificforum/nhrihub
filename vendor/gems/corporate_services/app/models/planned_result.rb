class PlannedResult < ActiveRecord::Base
  belongs_to :strategic_priority
  has_many :outcomes, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :outcomes

  default_scope ->{ order(:index) }

  # strip index if user has entered it
  before_create do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
    self.index = StrategicPlanIndexer.new(self,strategic_priority).next
  end

  after_destroy do |planned_result|
    lower_priorities = PlannedResult.
                         where(:strategic_priority_id => planned_result.strategic_priority_id).
                         select{|pr| pr >= self}
    lower_priorities.each{|pr| pr.decrement_index }
  end

  def self.all_with_associations
    collection = includes(:outcomes => {:activities => :performance_indicators}).all.sort_by(&:index)
      def collection.as_json(options = {})
        performance_indicators = {:performance_indicators => {:only => :id, :methods => :indexed_description}}
        activities = {:activities => {:only => [], :methods => :indexed_description, :include => performance_indicators}}
        outcomes = {:outcomes => {:only => [], :methods => :indexed_description, :include => activities}}
        planned_result_options = {:only => [], :methods => :indexed_description, :include => outcomes }
        super(planned_result_options)
      end
    collection
  end

  def <=>(other)
    self.index.split('.').map(&:to_i) <=> other.index.split('.').map(&:to_i)
  end

  def >=(other)
    [0,1].include?(self <=> other)
  end

  def as_json(options = {})
    default_options = {:except => [:updated_at, :created_at],
                       :methods => [:url, :indexed_description, :description, :outcomes, :create_outcome_url, :description_error]}
    options = options.blank? ? default_options : options
    super(options)
  end

  def description_error
    nil
  end

  # e.g. 2.1 -> 1.1
  def decrement_index_prefix(new_prefix)
    ar = index.split('.')
    ar[0] = new_prefix
    new_index = ar.join('.')
    update_attribute(:index, new_index)
    outcomes.each{|o| o.decrement_index_prefix(new_index)}
  end

  def decrement_index
    ar = index.split('.')
    new_suffix = ar.pop.to_i.pred.to_i
    ar << new_suffix
    new_index = ar.join('.')
    update_attribute(:index, ar.join('.'))
    outcomes.each{|o| o.decrement_index_prefix(new_index)}
  end

  def create_outcome_url
    Rails.application.routes.url_helpers.corporate_services_planned_result_outcomes_path(:en,id)
  end

  def indexed_description
    [index, description].join(' ')
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_strategic_priority_planned_result_path(:en, strategic_priority_id, id)
  end
end
