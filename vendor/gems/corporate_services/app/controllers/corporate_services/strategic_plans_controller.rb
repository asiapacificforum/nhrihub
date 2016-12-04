class CorporateServices::StrategicPlansController < ApplicationController
  def show
    @strategic_plans = StrategicPlan.all_with_current.sort # for the select box options
    if params[:id] == "current"
      #@strategic_plan = StrategicPlan.current.eager_loaded_associations.first
      @strategic_plan = StrategicPlan.load_sql
    else
      @strategic_plan = StrategicPlan.where(:id => params[:id]).eager_loaded_associations.first
    end
    respond_to do |format|
      format.html
      format.json {render :json => @strategic_plan }
      format.docx do
        send_file StrategicPlanReport.new(@strategic_plan).docfile
      end
    end
  end
end
