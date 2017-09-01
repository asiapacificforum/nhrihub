class PlannedResult < ActiveRecord::Base
  include StrategicPlanIndex
  belongs_to :strategic_priority
  has_many :outcomes, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :outcomes

  scope :in_current_strategic_plan, ->{ joins(:strategic_priority => :strategic_plan).merge(StrategicPlan.current) }


  def self.all_with_associations
    collection = in_current_strategic_plan.includes(:outcomes => {:activities => :performance_indicators}).all.sort_by(&:index)
      def collection.as_json(options = {})
        performance_indicators = { :performance_indicators => { :only => :id, :methods => :indexed_description}}
        activities             = { :activities =>             { :only => [],  :methods => :indexed_description, :include => performance_indicators}}
        outcomes               = { :outcomes =>               { :only => [],  :methods => :indexed_description, :include => activities}}
        planned_result_options = {:only => [], :methods => :indexed_description, :include => outcomes }
        super(planned_result_options)
      end
    collection
  end

  def as_json(options = {})
    default_options = {:except => [:updated_at, :created_at],
                       :methods => [:url, :indexed_description, :description, :outcomes, :create_outcome_url, :description_error]}
    options = default_options if (options.blank? || options.keys.include?(:status))
    super(options)
  end

  def description_error
    nil
  end

  def index_descendant
    outcomes
  end

  def index_parent
    strategic_priority
  end

  def create_outcome_url
    Rails.application.routes.url_helpers.corporate_services_planned_result_outcomes_path(:en,id)
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_strategic_priority_planned_result_path(:en, strategic_priority_id, id)
  end

  def dup
    planned_result = PlannedResult.new(attributes.slice("index", "description"))
    planned_result.outcomes << outcomes.map(&:dup)
    planned_result
  end
end
