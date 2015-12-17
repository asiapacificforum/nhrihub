class AreaTest
  def self.populate_test_data
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
end
