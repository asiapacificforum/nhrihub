require 'rails_helper'

describe "MediaAppearance#media_appearance_area" do
  before do
    @media_appearance = FactoryGirl.create(:media_appearance)
    area1 = FactoryGirl.create(:area)
    @media_appearance.areas << area1
    2.times do
      subarea = FactoryGirl.create(:subarea, :area_id => area1.id)
      @media_appearance.subareas << subarea
    end
    2.times do
      subarea = FactoryGirl.create(:subarea, :area_id => area1.id)
    end
    @media_appearance.save
  end

  it "should return a formatted hash of area and subareas" do
    expect(@media_appearance.media_appearance_areas).to eq [{:area_id => 1, :subarea_ids => [1,2]}]
  end
end
