log = (str)->
  re = new RegExp('phantomjs','gi')
  unless re.test navigator.userAgent
    console.log str

load_variables = ->
  window.strategic_plan_data = MagicLamp.loadJSON("strategic_plan_data")
  #window.all_mandates = []
  #window.all_agencies = []
  #window.complaint_bases = []
  #window.next_case_reference = ""
  #window.all_users = []
  #window.all_categories = []
  #window.permitted_filetypes = []
  #window.maximum_filesize = 5
  #window.filter_criteria        = MagicLamp.loadJSON("complaint_filter_criteria")
  #window.all_good_governance_complaint_bases = MagicLamp.loadJSON("all_good_governance_complaint_bases")
  #window.all_human_rights_complaint_bases = MagicLamp.loadJSON("all_human_rights_complaint_bases")
  #window.all_special_investigations_unit_complaint_bases = MagicLamp.loadJSON("all_special_investigations_unit_complaint_bases")
  #window.all_staff = MagicLamp.loadJSON("all_staff")
  #MagicLamp.load("strategic_plan_page") # that's the show.haml file being loaded

get_script_under_test = (done)->
  $.getScript("/assets/corporate_services/strategic_plan.js").
    done( ->
      log "(Strategic plan page) javascript was loaded"
      done()).
    fail( (jqxhr, settings, exception) ->
      log "Triggered ajaxError handler"
      log settings
      log exception)

#reset_page = ->
  #complaints.set('filter_criteria', window.filter_criteria)
  #complaints.set('complaints',[])

describe "strategic plan page", ->
  before (done)->
    load_variables()
    get_script_under_test(done)

  #after ->
    #reset_page()

  it "loads all fixtures", ->
    expect($(".h1_select:selected",'.magic-lamp').text()).to.match /Strategic Plan: Current reporting year/
    expect(typeof(simulant)).to.not.equal("undefined")
    return

  it "validates strategic priority", ->
    strategic_priority = strategic_plan.findAllComponents('sp')[0]
    expect(strategic_priority.get('description_error')).to.equal false
    expect(strategic_priority.get('priority_level_error')).to.equal false
    expect(strategic_priority.validate()).to.equal true
    expect(strategic_priority.get('description_error')).to.equal false
    expect(strategic_priority.get('priority_level_error')).to.equal false

  it "declares invalid strategic priority with blank string value for description", ->
    strategic_priority = strategic_plan.findAllComponents('sp')[0]
    strategic_priority.set('description',"   ")
    expect(strategic_priority.validate()).to.equal false
    expect(strategic_priority.get('description_error')).to.equal true

  it "declares invalid strategic priority with null string value for description", ->
    strategic_priority = strategic_plan.findAllComponents('sp')[0]
    strategic_priority.set('description',null)
    expect(strategic_priority.validate()).to.equal false
    expect(strategic_priority.get('description_error')).to.equal true

  it "declares invalid strategic priority with blank string value for priority level", ->
    strategic_priority = strategic_plan.findAllComponents('sp')[0]
    strategic_priority.set('priority_level',"  ")
    expect(strategic_priority.validate()).to.equal false
    expect(strategic_priority.get('priority_level_error')).to.equal true

  it "declares invalid strategic priority with null string value for priority level", ->
    strategic_priority = strategic_plan.findAllComponents('sp')[0]
    strategic_priority.set('priority_level',null)
    expect(strategic_priority.validate()).to.equal false
    expect(strategic_priority.get('priority_level_error')).to.equal true

  it "validates planned result", ->
    planned_result = strategic_plan.findAllComponents('pr')[0]
    expect(planned_result.validate()).to.equal true
    expect(planned_result.get('description_error')).to.equal false

  it "declares invalid planned result with null description", ->
    planned_result = strategic_plan.findAllComponents('pr')[0]
    planned_result.set('description',null)
    expect(planned_result.validate()).to.equal false
    expect(planned_result.get('description_error')).to.equal true

  it "declares invalid planned result with empty string description", ->
    planned_result = strategic_plan.findAllComponents('pr')[0]
    planned_result.set('description',"  ")
    expect(planned_result.validate()).to.equal false
    expect(planned_result.get('description_error')).to.equal true

  it "validates outcome", ->
    outcome = strategic_plan.findAllComponents('outcome')[0]
    expect(outcome.validate()).to.equal true
    expect(outcome.get('description_error')).to.equal false

  it "declares invalid outcome with null description", ->
    outcome = strategic_plan.findAllComponents('outcome')[0]
    outcome.set('description',null)
    expect(outcome.validate()).to.equal false
    expect(outcome.get('description_error')).to.equal true

  it "declares invalid outcome with empty string description", ->
    outcome = strategic_plan.findAllComponents('outcome')[0]
    outcome.set('description',"  ")
    expect(outcome.validate()).to.equal false
    expect(outcome.get('description_error')).to.equal true

  it "validates activity", ->
    activity = strategic_plan.findAllComponents('activity')[0]
    expect(activity.validate()).to.equal true
    expect(activity.get('description_error')).to.equal false

  it "declares invalid activity with null description", ->
    activity = strategic_plan.findAllComponents('activity')[0]
    activity.set('description',null)
    expect(activity.validate()).to.equal false
    expect(activity.get('description_error')).to.equal true

  it "declares invalid activity with empty string description", ->
    activity = strategic_plan.findAllComponents('activity')[0]
    activity.set('description',"  ")
    expect(activity.validate()).to.equal false
    expect(activity.get('description_error')).to.equal true

  it "validates performance indicator", ->
    performance_indicator = strategic_plan.findAllComponents('pi')[0]
    expect(performance_indicator.validate()).to.equal true
    expect(performance_indicator.get('description_error')).to.equal false

  it "declares invalid performance indicator with null description", ->
    performance_indicator = strategic_plan.findAllComponents('pi')[0]
    performance_indicator.set('description',null)
    expect(performance_indicator.validate()).to.equal false
    expect(performance_indicator.get('description_error')).to.equal true

  it "declares invalid performance indicator with empty string description", ->
    performance_indicator = strategic_plan.findAllComponents('pi')[0]
    performance_indicator.set('description',"  ")
    expect(performance_indicator.validate()).to.equal false
    expect(performance_indicator.get('description_error')).to.equal true
