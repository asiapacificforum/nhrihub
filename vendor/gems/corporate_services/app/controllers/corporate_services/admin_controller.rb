class CorporateServices::AdminController < ApplicationController
  def index
    @start_date = StrategicPlanStartDate.new
  end
end
