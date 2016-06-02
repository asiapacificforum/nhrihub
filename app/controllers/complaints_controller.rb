class ComplaintsController < ApplicationController
  def index
    @complaints = Complaint.all
    @mandates = Mandate.all
    @agencies = Agency.all
    @complaint_bases = [ GoodGovernance::ComplaintBasis.named_list,
                         Nhri::ComplaintBasis.named_list,
                         Siu::ComplaintBasis.named_list]
    @next_case_reference = Complaint.next_case_reference
    @users = User.all
  end

  def create
    complaint = Complaint.new(complaint_params)
    complaint.status_changes_attributes = [{:user_id => @current_user.id, :status_humanized => "open"}]
    if complaint.save
      render :json => complaint, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def update
    complaint = Complaint.find(params[:id])
    params[:complaint][:status_changes_attributes] = [{:user_id => @current_user.id, :status_humanized => params[:complaint].delete(:current_status_humanized)}]
    if complaint.update(complaint_params)
      render :json => complaint, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  private
  def complaint_params
    params.require(:complaint).permit( :case_reference, :complainant, :village, :phone, :current_assignee_id,
                                       :mandate_ids => [], :good_governance_complaint_basis_ids => [],
                                       :special_investigations_unit_complaint_basis_ids => [],
                                       :human_rights_complaint_basis_ids => [],
                                       :status_changes_attributes => [:user_id, :status_humanized])
  end
end
