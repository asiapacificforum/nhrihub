class Outcome < ActiveRecord::Base
  belongs_to :planned_result
  has_many :activities, :autosave => true, :dependent => :destroy

  default_scope ->{ order(:id) } # this naturally orders by index

  # strip index if user has entered it
  before_save do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
  end

  def as_json(options={})
    super(:except => [:updated_at, :created_at],
          :methods => [:indexed_description, :description, :id, :url, :create_activity_url, :activities])
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

  def index
    prefix = planned_result.index
    last_digit = all_in_planned_result.sort_by(&:id).index(self).succ.to_s
    [prefix, last_digit].join('.')
  end

  def all_in_planned_result
    Outcome.where(:planned_result_id => planned_result_id)
  end
end
