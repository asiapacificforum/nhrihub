class OutreachMedia::MediaController < ApplicationController
  def index
    @media_appearances = MediaAppearance.all
  end

end
