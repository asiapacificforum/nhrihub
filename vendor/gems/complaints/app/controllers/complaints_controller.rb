class ComplaintsController < ApplicationController
  def index
    #@complaints = Complaint.all
    @complaints = Complaint.includes(:assigns,
                                     :mandate,
                                     {:status_changes => :complaint_status},
                                     {:complaint_good_governance_complaint_bases=>:good_governance_complaint_basis},
                                     {:complaint_special_investigations_unit_complaint_bases => :special_investigations_unit_complaint_basis},
                                     {:complaint_human_rights_complaint_bases=>:human_rights_complaint_basis},
                                     {:complaint_agencies => :agency},
                                     :communications,
                                     :complaint_documents,
                                     :reminders,:notes).sort.reverse
    @mandates = Mandate.all.sort_by(&:name)
    @agencies = Agency.all
    @complaint_bases = [ CorporateServices::ComplaintBasis.named_list,
                        GoodGovernance::ComplaintBasis.named_list,
                        Nhri::ComplaintBasis.named_list,
                        Siu::ComplaintBasis.named_list ]
    @next_case_reference = Complaint.next_case_reference
    @users = User.all
    @good_governance_complaint_bases = GoodGovernance::ComplaintBasis.all
    @human_rights_complaint_bases = Nhri::ComplaintBasis.all
    @special_investigations_unit_complaint_bases = Siu::ComplaintBasis.all
    @staff = User.staff.order(:lastName,:firstName).select(:id,:firstName,:lastName)
    @maximum_filesize = ComplaintDocument.maximum_filesize * 1000000
    @permitted_filetypes = ComplaintDocument.permitted_filetypes.to_json
    @communication_maximum_filesize    = CommunicationDocument.maximum_filesize * 1000000
    @communication_permitted_filetypes = CommunicationDocument.permitted_filetypes.to_json
    @statuses = ComplaintStatus.select(:id, :name).all
    respond_to do |format|
      format.html
      format.docx do
        send_file ComplaintsReport.new(@complaints).docfile
      end
    end
  end

  def create
    params[:complaint].delete(:current_status_humanized)
    complaint = Complaint.new(complaint_params)
    complaint.status_changes_attributes = [{:user_id => current_user.id, :name => "Under Evaluation"}]
    if complaint.save
      render :json => complaint, :status => 200
    else
      render :plain => complaint.errors.full_messages, :status => 500
    end
  end

  def update
    complaint = Complaint.find(params[:id])
    params[:complaint][:status_changes_attributes] = [{:user_id => current_user.id, :name => params[:complaint].delete(:current_status_humanized)}]
    if complaint.update(complaint_params)
      render :json => complaint, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    complaint = Complaint.find(params[:id])
    complaint.destroy
    head :ok
  end

  def show
    @complaint = Complaint.find(params[:id])
    respond_to do |format|
      format.docx do
        send_file ComplaintReport.new(@complaint,current_user).docfile
      end
    end
  end

  private
  def complaint_params
    params.require(:complaint).permit( :case_reference, :firstName, :lastName, :chiefly_title, :village, :phone, :new_assignee_id,
                                       :dob, :email, :complained_to_subject_agency, :desired_outcome, :gender, :details,
                                       :mandate_name, :date_received, :imported, :good_governance_complaint_basis_ids => [],
                                       :special_investigations_unit_complaint_basis_ids => [],
                                       :human_rights_complaint_basis_ids => [],
                                       :status_changes_attributes => [:user_id, :name],
                                       :agency_ids => [],
                                       :complaint_documents_attributes => [:file, :title, :filename, :original_type, :filesize, :lastModifiedDate],
                                     )
  end
end

