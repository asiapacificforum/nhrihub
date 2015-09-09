def populate_areas
  ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"].each do |a|
    Area.create(:name => a)
  end
  human_rights_id = Area.where(:name => 'Human Rights').first.id
  [{:area_id => human_rights_id, :name => "Violation", :full_name => "Violation"},
  {:area_id => human_rights_id, :name => "Education activities", :full_name => "Education activities"},
  {:area_id => human_rights_id, :name => "Office reports", :full_name => "Office reports"},
  {:area_id => human_rights_id, :name => "Universal periodic review", :full_name => "Universal periodic review"},
  {:area_id => human_rights_id, :name => "CEDAW", :full_name => "Convention on the Elimination of All Forms of Discrimination against Women"},
  {:area_id => human_rights_id, :name => "CRC", :full_name => "Convention on the Rights of the Child"},
  {:area_id => human_rights_id, :name => "CRPD", :full_name => "Convention on the Rights of Persons with Disabilities"}].each do |attrs|
    Subarea.create(attrs)
  end

  good_governance_id = Area.where(:name => "Good Governance").first.id

  [{:area_id => good_governance_id, :name => "Violation", :full_name => "Violation"},
  {:area_id => good_governance_id, :name => "Office report", :full_name => "Office report"},
  {:area_id => good_governance_id, :name => "Office consultations", :full_name => "Office consultations"}].each do |attrs|
    Subarea.create(attrs)
  end
end

populate_areas

MagicLamp.define do
  fixture(:name => 'media_appearance_data') do
    FactoryGirl.create(:media_appearance, :title => "Fantasy land",
                                          :created_at => Date.new(2015,1,1),
                                          :description => {:areas => [{:name => "Human Rights", :subareas => [] }]})
    FactoryGirl.create(:media_appearance, :title => "May the force be with you",
                                          :created_at => Date.new(2014,1,1),
                                          :description => {:areas => [{:name => "Human Rights", :subareas => [] },{:name => "Human Wrongs", :subareas => [] }]})
    6.times do
      FactoryGirl.create(:media_appearance, :title => Faker::Lorem.sentence(5).gsub(/f/i,"b"),
                                            :created_at => Date.new(2014,1,1),
                                            :description => {:areas => [{:name => "Special Investigations Unit", :subareas => []}]})
    end
    MediaAppearance.all
  end

  fixture(:name => 'media_appearance_page') do
    @areas = Area.all
    render :partial => 'outreach_media/media_appearances/index'
  end
end
