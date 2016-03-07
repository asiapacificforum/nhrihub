class Nhri::AdvisoryCouncil::IssuesController < ApplicationController
  def index
    @advisory_council_issues = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.includes(:subareas, :violation_severity, :positivity_rating, :notes, :reminders, :areas => :subareas).all
    @areas = Area.includes(:subareas).all
    @subareas = Subarea.extended
    @advisory_council_issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new
  end

  def create
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.new(issue_params)
    if issue.save
      render :json => issue, :status => 200
    else
      render :nothing => true, :status => 500
    end
  end

  def destroy
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.find(params[:id])
    issue.destroy
    render :nothing => true, :status => 200
  end

  def update
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.find(params[:id])
    issue.update_attributes(issue_params)
    render :json => issue, :status => 200
  end

  def show
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.find(params[:id])
    send_opts = { :filename => issue.original_filename,
                  :type => issue.original_type,
                  :disposition => :attachment }
    send_file issue.file.to_io, send_opts
  end

  private
  def issue_params
    params["advisory_council_issue"]["user_id"] = current_user.id
    params.
      require(:advisory_council_issue).
      permit(:title,
             :affected_people_count,
             :positivity_rating_id,
             :violation_severity_id,
             :file,
             :remove_file,
             :original_filename,
             :filesize,
             :original_type,
             :lastModifiedDate,
             :user_id,
             :article_link,
             :performance_indicator_ids => [],
             :area_ids => [],
             :subarea_ids => [])
  end

end