require 'reminders_controller'

class Nhri::IccReferenceDocument::RemindersController < RemindersController
  # methods must be included here in order to control permissions
  def create
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  protected
  def reminder_params
    params[:reminder][:remindable_id] = params[:icc_reference_document_id]
    params[:reminder][:remindable_type] = 'IccReferenceDocument'
    super
  end
end

