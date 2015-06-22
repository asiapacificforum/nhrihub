class PlannedResult < ActiveRecord::Base
  belongs_to :strategic_priority

  def as_json(options = {})
    super(:except => [:updated_at, :created_at],
          :methods => [:update_url, :indexed_description])
  end

  def indexed_description
    first_digit = strategic_priority.priority_level.to_s
    second_digit = all_in_strategic_priority.sort_by(&:id).index(self).succ.to_s
    index = [first_digit, second_digit].join('.')
    [index, description].join(' ')
  end

  def update_url
    Rails.application.routes.url_helpers.corporate_services_strategic_priority_planned_result_path(:en, strategic_priority_id, id)
  end

  def all_in_strategic_priority
    PlannedResult.where(:strategic_priority_id => strategic_priority_id)
  end

  #def create_url
    #Rails.application.routes.url_helpers.corporate_services_strategic_priority_planned_results_path(:en, 'strategic_priority_id')
  #end
end
