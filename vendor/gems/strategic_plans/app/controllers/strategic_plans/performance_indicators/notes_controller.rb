require 'notes_controller'

class StrategicPlans::PerformanceIndicators::NotesController < NotesController
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  private
  def note_params
    params[:note][:notable_id] = params[:performance_indicator_id]
    params[:note][:notable_type] = "PerformanceIndicator"
    super
  end
end
