class CorporateServices::StrategicPlansController < ApplicationController
  def show
    @strategic_plan = StrategicPlan.where(:id => params[:id]).eager_loaded_associations.first
    @title = t('.heading', :title => @strategic_plan.title)
    respond_to do |format|
      format.html
      format.json {render :json => @strategic_plan }
      format.docx do
        send_file StrategicPlanReport.new(@strategic_plan).docfile
      end
    end
  end

  def create
    @strategic_plan = StrategicPlan.new(strategic_plan_params)
    if @strategic_plan.save
      render :json => @strategic_plan
    else
      render :status => 500
    end
  end

  def destroy
    @strategic_plan = StrategicPlan.find(params[:id])
    if @strategic_plan.destroy
      head 200
    else
      head 500
    end
  end

  private
  def strategic_plan_params
    params.require(:strategic_plan).permit(:title, :copy)
  end
end
