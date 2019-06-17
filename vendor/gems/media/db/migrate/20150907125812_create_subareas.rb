class CreateSubareas < ActiveRecord::Migration[4.2]
  def change
    create_table :subareas, :force => true do |t|
      t.text :name
      t.text :full_name
      t.references :area
      t.timestamps
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
end
