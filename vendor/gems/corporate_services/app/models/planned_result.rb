class PlannedResult < ActiveRecord::Base
  belongs_to :strategic_priority
  has_many :outcomes, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :outcomes

  default_scope ->{ order(:id) }

  # strip index if user has entered it
  before_save do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
    previous_index = PlannedResult.count.zero? ? strategic_priority.priority_level.to_s+".0" : PlannedResult.last.index
    ar = previous_index.split('.')
    self.index = ar.push(ar.pop.to_i.succ.to_s).join('.')
  end

  def self.all_with_associations
    collection = includes(:outcomes => {:activities => :performance_indicators}).all.sort_by(&:index)
      def collection.as_json(options = {})
        performance_indicators = {:performance_indicators => {:only => :id, :methods => :indexed_description}}
        activities = {:activities => {:methods => :indexed_description, :include => performance_indicators}}
        outcomes = {:outcomes => {:methods => :indexed_description, :include => activities}}
        planned_result_options = {:methods => :indexed_description, :include => outcomes }
        super(planned_result_options)
      end
    collection
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
