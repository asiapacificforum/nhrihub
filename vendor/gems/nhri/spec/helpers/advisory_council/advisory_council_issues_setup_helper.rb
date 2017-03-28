require 'rspec/core/shared_context'

module AdvisoryCouncilIssueSetupHelper
  extend RSpec::Core::SharedContext
  def setup_database(type = :advisory_council_issue_with_file)
    setup_areas
    if type == :advisory_council_issue_with_file
      FactoryGirl.create(:advisory_council_issue,
                         :hr_area,
                         :file,
                         :reminders=>[] )
    elsif type == :advisory_council_issue_with_link
      FactoryGirl.create(:advisory_council_issue,
                         :hr_area,
                         :link,
                         :reminders=>[] )
    else
      FactoryGirl.create(:advisory_council_issue,
                         :hr_area,
                         :reminders=>[] )
    end
  end

  def add_a_second_article
    FactoryGirl.create(:advisory_council_issue,
                       :hr_area,
                       :reminders=>[] )
  end

  def add_reminder
    issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
    issue.reminders << FactoryGirl.create(:reminder, :reminder_type => 'weekly', :text => "don't forget the fruit gums mum", :users => [User.first])
    issue.save
  end

  def setup_articles
    FactoryGirl.create(:advisory_council_issue)
  end

  def setup_areas
    areas = ["Human Rights", "Good Governance", "Special Investigations Unit", "Corporate Services"]
    human_rights_subareas = ["Violation", "Education activities", "Office reports", "Universal periodic review", "CEDAW", "CRC", "CRPD"]
    good_governance_subareas = ["Violation", "Office report", "Office consultations"]

    areas.each do |a|
      Area.create(:name => a) unless Area.where(:name => a).exists?
    end

    human_rights_id = Area.where(:name => "Human Rights").first.id
    human_rights_subareas.each do |hrsa|
      Subarea.create(:name => hrsa, :area_id => human_rights_id) unless Subarea.where(:name => hrsa, :area_id => human_rights_id).exists?
    end

    good_governance_id = Area.where(:name => "Good Governance").first.id
    good_governance_subareas.each do |ggsa|
      Subarea.create(:name => ggsa, :area_id => good_governance_id) unless Subarea.where(:name => ggsa, :area_id => good_governance_id).exists?
    end
  end

  def setup_file_constraints
    SiteConfig['nhri.advisory_council_issue.filetypes'] = ['pdf']
    SiteConfig['nhri.advisory_council_issue.filesize'] = 3
  end
end
