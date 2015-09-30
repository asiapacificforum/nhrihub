DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

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

  #Subarea.create({:area_id => cs_area.id, :name => "XYZ"})
end

populate_areas

def populate_positivity_ratings
end


def populate_media_appearances
  ma = FactoryGirl.create(:media_appearance, :hr_area,
                                             :crc_subarea,
                                             :title => "Fantasy land",
                                             # this time is stored as its UTC equivalent 12/31/14
                                             # so the date method returns the intended value, 1/1/15
                                             :created_at => DateTime.new(2015,1,1,0,0,0,'-8'),
                                             :violation_coefficient => 10,
                                             :violation_severity => 5,
                                             :affected_people_count => 555)
  ma.positivity_rating = FactoryGirl.create(:positivity_rating, :rank => 5)
  ma.save

  ma = FactoryGirl.create(:media_appearance, :hr_area,
                                             :crc_subarea,
                                             :title => "May the force be with you",
                                             :created_at => DateTime.new(2014,1,1,0,0,0,'-8'),
                                             :violation_coefficient => 0.7,
                                             :violation_severity => 2,
                                             :affected_people_count => 55500000)
  ma.positivity_rating = FactoryGirl.create(:positivity_rating, :rank => 2)
  ma.save

  6.times do
    ma = FactoryGirl.create(:media_appearance,
                            :no_f_in_title,
                            :si_area,
                            :created_at => DateTime.new(2014,1,1,0,0,0,'-8'),
                            :violation_coefficient => 10,
                            :violation_severity => 9,
                            :affected_people_count => 55500000)
    ma.positivity_rating = FactoryGirl.create(:positivity_rating, :rank => 9)
    ma.save
  end
end



MagicLamp.define do
  fixture(:name => 'subareas_data') do
    Subarea.extended
  end

  fixture(:name => 'areas_data') do
    Area.all
  end

  # e.g. on page do this:  window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
  fixture(:name => 'media_appearance_data') do
    populate_media_appearances
    MediaAppearance.all
  end

  fixture(:name => 'new_media_appearance') do
    MediaAppearance.new
  end

  fixture(:name => 'create_media_appearance_url') do
    MediaAppearance.new.create_url
  end

  fixture(:name => 'media_appearance_page') do
    @areas = Area.all
    render :partial => 'outreach_media/media_appearances/index'
  end
end
