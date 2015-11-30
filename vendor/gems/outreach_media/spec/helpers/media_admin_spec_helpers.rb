require 'rspec/core/shared_context'

module MediaAdminSpecHelpers
  extend RSpec::Core::SharedContext

  def subareas
    page.all('.subarea .name').map(&:text)
  end

  def open_accordion_for_area(text)
    target_area = area_called(text)
    target_area.find('#subareas_link').click
    sleep(0.2) # transition
  end

  def area_called(text)
    page.find('.row.area', :text => text)
  end

  def new_filetype_button
    page.find("#new_outreach_media_filetype table button")
  end

  def set_filesize(val)
    page.find('input#filesize').set(val)
  end

  def delete_filetype(type)
    page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
  end

  def remove_add_delete_fileconfig_permissions
    ActionRole.
      joins(:action => :controller).
      where('actions.action_name' => ['create', 'destroy', 'update'],
            'controllers.controller_name' => ['outreach_media/filetypes','outreach_media/filesizes']).
      destroy_all
  end

  def create_default_areas
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
end
