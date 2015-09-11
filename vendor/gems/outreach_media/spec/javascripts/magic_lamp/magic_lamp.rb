def populate_areas

  hr_area = Area.create(:name => 'Human Rights')
  gg_area = Area.create(:name => "Good Governance")
  cs_area = Area.create(:name => "Corporate Services")
  si_area = Area.create(:name => "Special Investigations Unit")

 [{:area_id => hr_area.id, :name => "Violation", :full_name => "Violation"},
  {:area_id => hr_area.id, :name => "Education activities", :full_name => "Education activities"},
  {:area_id => hr_area.id, :name => "Office reports", :full_name => "Office reports"},
  {:area_id => hr_area.id, :name => "Universal periodic review", :full_name => "Universal periodic review"},
  {:area_id => hr_area.id, :name => "CEDAW", :full_name => "Convention on the Elimination of All Forms of Discrimination against Women"},
  {:area_id => hr_area.id, :name => "CRC", :full_name => "Convention on the Rights of the Child"},
  {:area_id => hr_area.id, :name => "CRPD", :full_name => "Convention on the Rights of Persons with Disabilities"}].each do |attrs|
    Subarea.create(attrs)
  end

 [{:area_id => gg_area.id, :name => "Violation", :full_name => "Violation"},
  {:area_id => gg_area.id, :name => "Office report", :full_name => "Office report"},
  {:area_id => gg_area.id, :name => "Office consultations", :full_name => "Office consultations"}].each do |attrs|
    Subarea.create(attrs)
  end

  Subarea.create({:area_id => cs_area.id, :name => "XYZ"})
end


def populate_media_appearances
  ma = FactoryGirl.create(:media_appearance, :hr_area,
                                             :crc_subarea,
                                             :gg_area,
                                             :title => "Fantasy land",
                                             :created_at => Date.new(2015,1,1))

  ma = FactoryGirl.create(:media_appearance, :hr_area,
                                             :crc_subarea,
                                             :title => "May the force be with you",
                                             :created_at => Date.new(2014,1,1))

  6.times do
    ma = FactoryGirl.create(:media_appearance, :no_f_in_title, :si_area, :created_at => Date.new(2014,1,1))
  end
end

populate_areas


MagicLamp.define do
  fixture(:name => 'subareas_data') do
    Subarea.all
  end

  fixture(:name => 'areas_data') do
    Area.all
  end

  fixture(:name => 'media_appearance_data') do
    populate_media_appearances
    MediaAppearance.all
  end

  fixture(:name => 'media_appearance_page') do
    @areas = Area.all
    render :partial => 'outreach_media/media_appearances/index'
  end
end
