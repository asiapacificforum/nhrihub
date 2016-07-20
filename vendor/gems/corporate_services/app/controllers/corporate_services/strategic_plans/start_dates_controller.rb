class CorporateServices::StrategicPlans::StartDatesController < ApplicationController
  def update
    params[:strategic_plan_start_date]["date(1i)"] = Date.today.year
    start_date = StrategicPlanStartDate.update_attribute(:date, params[:strategic_plan_start_date])
    render :json => {:date => start_date.strftime("%B %e")}, :status => 200
  end
end
