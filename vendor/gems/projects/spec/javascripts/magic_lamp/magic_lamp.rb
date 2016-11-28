require_relative './seed_data/projects_seed_data'

MagicLamp.define do
  fixture(:name => "projects") do
    ProjectsSeedData.initialize(:projects)
    {:projects => Project.all, :areas => Mandate.all}
  end

  fixture(:name => "model_name") do
    Project.to_s
  end

  fixture(:name => "agencies") do
    ProjectsSeedData.initialize(:agencies)
    all = Agency.all
    in_threes = all.in_groups_of(3)
    { :all => all, :in_threes => in_threes }
  end

  fixture(:name => "conventions") do
    ProjectsSeedData.initialize(:conventions)
    Convention.all
  end

  fixture(:name => "project_named_documents_titles") do
    ProjectDocument::NamedProjectDocumentTitles
  end

  fixture(:name => 'projects_page') do
    render :file => 'projects/index'
  end

  fixture(:name => 'project_types') do
    ProjectsSeedData.initialize(:project_types)
    ProjectType.all
  end

  fixture(:name => 'project_filter_criteria') do
    { :title => "",
      :area_ids => [],
      :area_rule => 'any',
      :agency_ids => [],
      :convention_ids => [],
      :agency_convention_rule => 'any',
      :project_type_ids => [],
      :project_type_rule => 'any',
      :performance_indicator_id => nil
    }
  end

end
