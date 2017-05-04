class DashboardController < ApplicationController
  def index
    @glacier_archives = GlacierArchive.all
  end
end
