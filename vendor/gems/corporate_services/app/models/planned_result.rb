class PlannedResult < ActiveRecord::Base
  belongs_to :strategic_priority

  default_scope ->{ order(:id) }

  def as_json(options = {})
    super(:except => [:updated_at, :created_at],
          :methods => [:url, :indexed_description, :description])
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
