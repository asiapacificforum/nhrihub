class PlannedResult < ActiveRecord::Base
  belongs_to :strategic_priority
  has_many :outcomes, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :outcomes

  default_scope ->{ order(:id) }

  # strip index if user has entered it
  before_save do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
  end

  def as_json(options = {})
    super(:except => [:updated_at, :created_at],
          :methods => [:url, :indexed_description, :description, :outcomes, :create_outcome_url, :description_error])
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

  def index
    first_digit = strategic_priority.priority_level.to_s
    second_digit = all_in_strategic_priority.sort_by(&:id).index(self).succ.to_s
    [first_digit, second_digit].join('.')
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_strategic_priority_planned_result_path(:en, strategic_priority_id, id)
  end

  def all_in_strategic_priority
    PlannedResult.where(:strategic_priority_id => strategic_priority_id)
  end

end
