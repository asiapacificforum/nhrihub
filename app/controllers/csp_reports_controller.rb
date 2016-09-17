class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token, :check_permissions, only: [:create]

  def index
    @csp_reports = CspReport.all.order("created_at DESC")
    render :partial => "index"
  end

  def create
    data = request.body.read
    attrs = JSON.parse(data)["csp-report"]
    report = CspReport.new(attrs)
    report.save!

    head :ok
  end
end

