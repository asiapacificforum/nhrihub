class Nhri::AdvisoryCouncil::IssuesController < ApplicationController
  include AttachedFile

  def index
    @advisory_council_issues = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.includes(:subareas, :notes, :reminders, :areas => :subareas).all
    @areas = Area.includes(:subareas).all
    @subareas = Subarea.extended
    @advisory_council_issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new
    respond_to do |format|
      format.html
      format.docx do
        send_file IssuesReport.new(@advisory_council_issues).docfile
      end
    end
  end

  def create
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new(issue_params)
    if issue.save
      render :json => issue, :status => 200
    else
      head :internal_server_error
    end
  end

  def destroy
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.find(params[:id])
    issue.destroy
    head :ok
  end

  def update
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.find(params[:id])
    issue.update_attributes(issue_params)
    render :json => issue, :status => 200
  end

  def show
    send_attached_file( Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.find(params[:id]))
  end

  private
  def issue_params
    if params[:advisory_council_issue][:file] == "_remove"
      params["advisory_council_issue"]["original_filename"] = nil
      params["advisory_council_issue"]["filesize"] = nil
      params["advisory_council_issue"]["original_type"] = nil
      params[:advisory_council_issue][:remove_file] = true
    end
    params["advisory_council_issue"]["user_id"] = current_user.id
    params.
      require(:advisory_council_issue).
      permit(:title,
             :affected_people_count,
             :file,
             :remove_file,
             :original_filename,
             :filesize,
             :original_type,
             :lastModifiedDate,
             :user_id,
             :article_link,
             :performance_indicator_ids => [], # it's from shared js and it's ignored
             :area_ids => [],
             :subarea_ids => [])
  end

end
