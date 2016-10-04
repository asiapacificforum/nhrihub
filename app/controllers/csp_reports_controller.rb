class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token, :check_permissions, only: [:create]

  def index
    @csp_reports = CspReport.all.order("created_at DESC")
    render :partial => "index"
  end

  def create
    data = request.body.read
    attrs = JSON.parse(data)["csp-report"]
    attrs.slice!(*CspReport.new.attributes.keys.map(&:dasherize))
    report = CspReport.new(attrs)
    report.save!

    head :ok
  end

  def clear_all
    CspReport.destroy_all
    @csp_reports = []
    render :partial => "index"
  end
end

