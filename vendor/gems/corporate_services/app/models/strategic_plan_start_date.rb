class StrategicPlanStartDate
  include ActiveModel::Model
  attr_accessor :date

  def initialize(attrs = {})
    @date = attrs[:date] || SiteConfig['corporate_services.strategic_plans.start_date']
  end

  def self.update_attribute(attr,val)
    new(:date => Date.new(*val.values.map(&:to_i))).save
  end

  def save
    SiteConfig['corporate_services.strategic_plans.start_date'] = date
  end

  def to_s
    Date.parse(date).strftime("%B %e")
  end
end
