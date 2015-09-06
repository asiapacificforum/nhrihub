class OutreachMedia::MediaAppearancesController < ApplicationController
  def index
    @media_appearances = MediaAppearance.all
    @areas = []
  end

end
