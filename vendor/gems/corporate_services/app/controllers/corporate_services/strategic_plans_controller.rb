class CorporateServices::StrategicPlansController < ApplicationController
  def show
    @strategic_plans = StrategicPlan.all_with_current.sort # for the select box options
    @strategic_priority = StrategicPriority.new
    if params[:id] == "current"
      #@strategic_plan = @strategic_plans.last # the current strategic plan
      @strategic_plan = StrategicPlan.current.includes(:strategic_priorities => {:planned_results => {:outcomes => {:activities => {:performance_indicators => [:media_appearances, :projects, :notes, :reminders]}}}}).first
    else
      @strategic_plan = StrategicPlan.where(:id => params[:id]).includes(:strategic_priorities => {:planned_results => {:outcomes => {:activities => {:performance_indicators => [:media_appearances, :projects, :notes, :reminders]}}}}).first
    end
    @strategic_priorities = @strategic_plan.strategic_priorities
    respond_to do |format|
      format.html
      format.json {render :json => @strategic_plan }
      format.docx do
        send_file StrategicPlanReport.new(StrategicPlan.most_recent).docfile
      end
    end
  end
end
