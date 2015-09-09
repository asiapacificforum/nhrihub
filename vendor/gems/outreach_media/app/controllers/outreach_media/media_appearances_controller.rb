class OutreachMedia::MediaAppearancesController < ApplicationController
  def index
    @media_appearances = MediaAppearance.all
    @areas = Area.all
    @subareas = Subarea.all
  end

end
