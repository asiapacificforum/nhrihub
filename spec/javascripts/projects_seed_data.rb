class ProjectsSeedData
  def self.initialize(model)
    self.send("init_#{model.to_s}")
  end

  def self.init_projects
    FactoryGirl.create(:good_governance_project)
    project = GoodGovernance::Project.first
    project.mandates = [FactoryGirl.create(:mandate, :key => 'human_rights')]
    project.save
    project
  end

  def self.init_mandates
    #Mandate.all
  end

  def self.init_agencies
  end

  def self.init_conventions
  end
end
