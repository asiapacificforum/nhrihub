require_relative './projects_seed_data'

MagicLamp.define do
  fixture(:name => "projects") do
    ProjectsSeedData.initialize(:projects)
    {:projects => GoodGovernance::Project.all, :mandates => Mandate.all}
  end

  fixture(:name => "model_name") do
    GoodGovernance::Project.to_s
  end

  fixture(:name => "agencies") do
    ProjectsSeedData.initialize(:agencies)
    Agency.all
  end

  fixture(:name => "conventions") do
    ProjectsSeedData.initialize(:conventions)
    Convention.all
  end

  fixture(:name => 'projects_page') do
    render :partial => 'projects/index'
  end
end
