class ComplaintsController < ApplicationController
  def index
    identifiers = Complaint.select(:id, :updated_at).all.inject({}) do |hash,complaint|
      key = "complaint_#{complaint.id}_#{complaint.updated_at.strftime("%s.%6L")}"
      hash[key]=complaint.id
      hash
    end

    all_complaints = Complaint.includes({:assigns => :assignee},
                          :mandates,
                          {:status_changes => [:user, :complaint_status]},
                          {:complaint_good_governance_complaint_bases=>:good_governance_complaint_basis},
                          {:complaint_special_investigations_unit_complaint_bases => :special_investigations_unit_complaint_basis},
                          {:complaint_human_rights_complaint_bases=>:human_rights_complaint_basis},
                          {:complaint_agencies => :agency},
                          {:communications => [:user, :communication_documents, :communicants]},
                          :complaint_documents,
                          {:reminders => :user},
                          {:notes =>[:author, :editor]}).where(:id => ids).sort

    cache_fetcher = BulkCacheFetcher.new(Rails.cache)
    complaints = cache_fetcher.fetch(identifiers) do |uncached_keys_and_ids|
      ids = uncached_keys_and_ids.values
      all_complaints.map(&:to_json)
    end

    @complaints = "[#{complaints.join(", ").html_safe}]".html_safe

    @mandates = Mandate.all.sort_by(&:name)
    @agencies = Agency.all
    @complaint_bases = [ StrategicPlans::ComplaintBasis.named_list,
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
    @permitted_filetypes = ComplaintDocument.permitted_filetypes
    @communication_maximum_filesize    = CommunicationDocument.maximum_filesize * 1000000
    @communication_permitted_filetypes = CommunicationDocument.permitted_filetypes
    @statuses = ComplaintStatus.select(:id, :name).all
    respond_to do |format|
      format.html do
        render :index, :layout => 'application_webpack'
      end
      format.docx do
        send_file ComplaintsReport.new(all_complaints).docfile
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
  rescue => e
    logger.error e
    head :internal_server_error
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
                                       :date, :imported, :good_governance_complaint_basis_ids => [],
                                       :special_investigations_unit_complaint_basis_ids => [],
                                       :human_rights_complaint_basis_ids => [],
                                       :status_changes_attributes => [:user_id, :name],
                                       :agency_ids => [], :mandate_ids => [],
                                       :complaint_documents_attributes => [:file, :title, :filename, :original_type, :filesize, :lastModifiedDate],
                                     )
  end
end

