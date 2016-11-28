log = (str)->
  re = new RegExp('phantomjs','gi')
  unless re.test navigator.userAgent
    console.log str

load_variables = ->
  window.projects_data          = MagicLamp.loadJSON("projects").projects
  window.model_name             = MagicLamp.loadRaw ("model_name")
  window.areas                  = MagicLamp.loadJSON("projects").areas
  window.agencies               = MagicLamp.loadJSON("agencies").all
  window.all_agencies_in_threes = MagicLamp.loadJSON("agencies").in_threes
  window.conventions            = MagicLamp.loadJSON("conventions")
  window.project_types          = MagicLamp.loadJSON("project_types")
  window.filter_criteria        = MagicLamp.loadJSON("project_filter_criteria")
  window.project_named_documents_titles = MagicLamp.loadJSON("project_named_documents_titles")
  window.permitted_filetypes = []
  window.maximum_filesize = 5
  window.planned_results        = []
  window.performance_indicators = []
  window.i18n_key               = "en.good_governance.index"
  MagicLamp.load("projects_page") # that's the _index partial being loaded

get_script_under_test = (done)->
  $.getScript("/assets/projects.js").
    done( ->
      log "(Projects page) javascript was loaded"
      done()).
    fail( (jqxhr, settings, exception) ->
      log "Triggered ajaxError handler"
      log settings
      log exception)

describe "edit project", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  it "loads all fixtures", ->
    expect($("h1",'.magic-lamp').text()).to.equal "Projects"
    expect($(".project", '.magic-lamp').length).to.equal 1
    expect(typeof(simulant)).to.not.equal("undefined")
    return

  it "restores pre-edit checkbox values", ->
    expect(projects.findAllComponents('project')[0].get('area_ids')).to.eql [1]
    edit_start = $("#projects .project i[id $='edit_start']").first()
    projects.findAllComponents('project')[0].editor.edit_start(edit_start) # start edit
    expect($('.area input:checkbox').first().prop('checked')).to.be.true
    _($('.area input:checkbox')).each (el)-> $(el).prop('checked',false) # uncheck the checkbox
    expect($('.area input:checkbox').first().prop('checked')).to.be.false
    edit_cancel = $("#projects .project i[id $='edit_cancel']").first()
    projects.findAllComponents('project')[0].editor.edit_cancel(edit_cancel) # cancel edit
    projects.findAllComponents('project')[0].editor.edit_start(edit_start) # start edit again
    expect($('.area input:checkbox').first().prop('checked')).to.be.true
    return

describe "matching title", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    projects.set('filter_criteria', window.filter_criteria)
    projects.set('projects',[])

  it "when filter_criteria.title is empty", ->
    projects.set('projects',[{title:"Foo"}])
    projects.set('filter_criteria.title',"")
    project = projects.findComponent('project')
    expect(project.matches_title()).to.be.true
    expect(project.include()).to.be.true
    expect(project.get('include')).to.be.true

  it "when filter_criteria.title is whitespace", ->
    projects.set('projects',[{title:"Foo"}])
    projects.set('filter_criteria.title',"  ")
    project = projects.findComponent('project')
    expect(project.matches_title()).to.be.true
    expect(project.include()).to.be.true
    expect(project.get('include')).to.be.true

  it "when filter_criteria.title has a non-matching value", ->
    projects.set('projects',[{title:"bar"}])
    projects.set('filter_criteria.title',"foo")
    project = projects.findComponent('project')
    expect(project.matches_title()).to.be.false
    expect(project.include()).to.be.false
    expect(project.get('include')).to.be.false

  it "when filter_criteria.title has a matching value", ->
    projects.set('projects',[{title:"got some foo in my porridge"}])
    projects.set('filter_criteria.title',"Foo")
    project = projects.findComponent('project')
    expect(project.matches_title()).to.be.true
    expect(project.include()).to.be.true
    expect(project.get('include')).to.be.true

describe "matching area", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    projects.set('filter_criteria', window.filter_criteria)
    projects.set('projects',[])

  describe "when filter_criteria.area_ids is empty", ->
    before ->
      projects.set('filter_criteria.area_ids',[])

    it "when project area_ids is empty", ->
      projects.set('projects',[{area_ids : [] }])
      project = projects.findComponent('project')
      expect(project.matches_area()).to.be.true
      expect(project.get('include')).to.be.true

    it "when project area_ids is not empby", ->
      projects.set('projects',[{area_ids : [3,4] }])
      project = projects.findComponent('project')
      expect(project.matches_area()).to.be.true
      expect(project.get('include')).to.be.true

  describe "when filter_criteria.area_ids is not empty", ->
    before ->
      projects.set('filter_criteria.area_ids',[3,4])

    it "when project area_ids is empty", ->
      projects.set('projects',[{area_ids : [] }])
      project = projects.findComponent('project')
      expect(project.matches_area()).to.be.false
      expect(project.get('include')).to.be.false

    it "when project area_ids has matching ids", ->
      projects.set('projects',[{area_ids : [3,4] }])
      project = projects.findComponent('project')
      expect(project.matches_area()).to.be.true
      expect(project.get('include')).to.be.true

    it "when project area_ids has partially matching ids", ->
      projects.set('projects',[{area_ids : [4] }])
      project = projects.findComponent('project')
      expect(project.matches_area()).to.be.true
      expect(project.get('include')).to.be.true

describe "matching agencies", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    projects.set('filter_criteria', window.filter_criteria)
    projects.set('projects',[])

  describe "when filter_criteria.agency_ids is empty", ->
    before ->
      projects.set('filter_criteria.agency_ids',[])

      it "matches when project agency_ids is empty", ->
        projects.set('projects',[{agency_ids : [] }])
        project = projects.findComponent('project')
        expect(project.matches_agency()).to.be.true
        expect(project.get('include')).to.be.true

      it "matches when project agency_ids is not empby", ->
        projects.set('projects',[{agency_ids : [3,4]}])
        project = projects.findComponent('project')
        expect(project.matches_agency()).to.be.true
        expect(project.get('include')).to.be.true

  describe "when filter_criteria.agency_ids is not empty", ->
    before ->
      projects.set('filter_criteria.agency_ids',[3,4])

    it "does not match when project agency_ids is empty", ->
      projects.set('projects',[{agency_ids : [] }])
      project = projects.findComponent('project')
      expect(project.matches_agency()).to.be.false
      expect(project.get('include')).to.be.false

    it "matches when project agency_ids has all matching ids", ->
      projects.set('projects',[{agency_ids : [3] }])
      project = projects.findComponent('project')
      expect(project.matches_agency()).to.be.true
      expect(project.get('include')).to.be.true

describe "matching conventions", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    projects.set('filter_criteria', window.filter_criteria)
    projects.set('projects',[])

  describe "when filter_criteria.convention_ids is empty", ->
    before ->
      projects.set('filter_criteria.convention_ids',[])

    it "matches when project convention_ids is empty", ->
      projects.set('projects',[{ convention_ids : [] }])
      project = projects.findComponent('project')
      expect(project.matches_convention()).to.be.true
      expect(project.get('include')).to.be.true

    it "matches when project conventions_ids is not empty", ->
      projects.set('projects',[{ convention_ids : [5] }])
      project = projects.findComponent('project')
      expect(project.matches_convention()).to.be.true
      expect(project.get('include')).to.be.true

describe "matching project_type", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    projects.set('filter_criteria', window.filter_criteria)
    projects.set('projects',[])

  describe "when filter_criteria.project_type_ids is empty", ->
    before ->
      projects.set('filter_criteria.project_type_ids',[])

    it "when project project_type_ids is empty", ->
      projects.set('projects',[{project_type_ids : [] }])
      project = projects.findComponent('project')
      expect(project.matches_project_type()).to.be.true
      expect(project.get('include')).to.be.true

    it "when project project_type_ids is not empby", ->
      projects.set('projects',[{project_type_ids : [3,4] }])
      project = projects.findComponent('project')
      expect(project.matches_project_type()).to.be.true
      expect(project.get('include')).to.be.true

  describe "when filter_criteria.project_type_ids is not empty", ->
    before ->
      projects.set('filter_criteria.project_type_ids',[3,4])

    it "when project project_type_ids is empty", ->
        projects.set('projects',[{project_type_ids : [] }])
        project = projects.findComponent('project')
        expect(project.matches_project_type()).to.be.false
        expect(project.get('include')).to.be.false

      it "when project project_type_ids has matching ids", ->
        projects.set('projects',[{project_type_ids : [3,4] }])
        project = projects.findComponent('project')
        expect(project.matches_project_type()).to.be.true
        expect(project.get('include')).to.be.true

      it "when project project_type_ids has partially matching ids", ->
        projects.set('projects',[{project_type_ids : [4] }])
        project = projects.findComponent('project')
        expect(project.matches_project_type()).to.be.true
        expect(project.get('include')).to.be.true

describe "matching performance indicator", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    projects.set('filter_criteria', window.filter_criteria)
    projects.set('projects',[])

  describe "when filter_criterion.performance_indicator is blank", ->
    before ->
      projects.set('filter_criteria.performance_indicator',null)

    it "should match project with null performance_indicator_id", ->
      projects.set('projects',[{performance_indicator : null}])
      project = projects.findComponent('project')
      expect(project.matches_performance_indicator()).to.be.true
      expect(project.get('include')).to.be.true

    it "should match project with undefined performance_indicator_id", ->
      projects.set('projects',[{performance_indicator : undefined}])
      project = projects.findComponent('project')
      expect(project.matches_performance_indicator()).to.be.true
      expect(project.get('include')).to.be.true

    it "should match project with empty string performance_indicator_id", ->
      projects.set('projects',[{performance_indicator : " "}])
      project = projects.findComponent('project')
      expect(project.matches_performance_indicator()).to.be.true
      expect(project.get('include')).to.be.true

  describe "when filter_criterion.performance_indicator has numeric value", ->
    before ->
      projects.set('filter_criteria.performance_indicator_id',42)

    it "should match project with matching performance_indicator_id", ->
      projects.set('projects',[{performance_indicator_id : 42}])
      project = projects.findComponent('project')
      expect(project.matches_performance_indicator()).to.be.true
      expect(project.get('include')).to.be.true

    it "should not match project with non-matching performance_indicator_id", ->
      projects.set('projects',[{performance_indicator_id : 43}])
      project = projects.findComponent('project')
      expect(project.matches_performance_indicator(),"matches_performance_indicator()").to.be.false
      expect(project.get('include')).to.be.false

    it "should not match project with undefined performance_indicator_id", ->
      projects.set('projects',[{performance_indicator_id : undefined}])
      project = projects.findComponent('project')
      expect(project.matches_performance_indicator(),"matches_performance_indicator()").to.be.false
      expect(project.get('include')).to.be.false

describe "filter reset", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  after ->
    projects.set('filter_criteria', window.filter_criteria)
    projects.set('projects',[])

  it "should reset the title input filter value", ->
    $('input#title').val("blerky schmoo")
    simulant.fire($('input#title')[0],'change')
    $('i.erase').trigger('click')
    expect($('input#title').val()).to.equal ""
