class CspReportsController < ApplicationController
  skip_before_action :verify_authenticity_token, :check_permissions, only: [:create]

  def index
    @reports = CspReport.all.order("created_at DESC")
  end

  def create
    data = request.body.read

    h = JSON.parse(data)["csp-report"]
    report = CspReport.new(h)
    report.save!

    head :ok
  end
end

