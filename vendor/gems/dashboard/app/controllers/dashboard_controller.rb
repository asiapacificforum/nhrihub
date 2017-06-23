class DashboardController < ApplicationController
  def index
    @application_data_backups = ApplicationDataBackup.all
  end
end
