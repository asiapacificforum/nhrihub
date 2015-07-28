class Activity < ActiveRecord::Base
  belongs_to  :outcome
  default_scope ->{ order(:id) } # this naturally orders by index

  # strip index if user has entered it
  before_save do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
  end

  def as_json(options={})
    super(:except => [:updated_at, :created_at],
          :methods => [:indexed_description, :description, :performance_indicator, :target, :id, :url])
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_outcome_activity_path(:en,outcome_id,id)
  end

  def indexed_description
    if description.blank?
      ""
    else
      [index, description].join(' ')
    end
  end

  def index
    prefix = outcome.index
    last_digit = all_in_outcome.sort_by(&:id).index(self).succ.to_s
    [prefix, last_digit].join('.')
  end

  def all_in_outcome
    Activity.where(:outcome_id => outcome_id)
  end
end
