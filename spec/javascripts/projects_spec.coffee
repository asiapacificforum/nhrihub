log = (str)->
  re = new RegExp('phantomjs','gi')
  unless re.test navigator.userAgent
    console.log str


describe "edit project", ->
  before (done)->
    window.projects_data          = MagicLamp.loadJSON("projects").projects
    window.model_name             = MagicLamp.loadRaw ("model_name")
    window.mandates               = MagicLamp.loadJSON("projects").mandates
    window.agencies               = MagicLamp.loadJSON("agencies")
    window.conventions            = MagicLamp.loadJSON("conventions")
    window.planned_results        = []
    window.performance_indicators = []
    window.i18n_key               = "en.good_governance.index"
    MagicLamp.load("projects_page") # that's the _index partial being loaded
    $.getScript("/assets/projects.js").
      done( ->
        log "(Projects page) javascript was loaded"
        done()).
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

  it "loads all fixtures", ->
    expect($("h1",'.magic-lamp').text()).to.equal "Good Governance Projects"
    expect($(".project", '.magic-lamp').length).to.equal 1
    expect(typeof(simulant)).to.not.equal("undefined")
    return

  it "restores pre-edit checkbox values", ->
    expect(projects.findAllComponents('project')[0].get('mandate_ids')).to.eql [1]
    edit_start = $("#projects .project i[id $='edit_start']").first()
    projects.findAllComponents('project')[0].editor.edit_start(edit_start) # start edit
    expect($('.mandate input:checkbox').first().prop('checked')).to.be.true
    _($('.mandate input:checkbox')).each (el)-> $(el).prop('checked',false) # uncheck the checkbox
    expect($('.mandate input:checkbox').first().prop('checked')).to.be.false
    edit_cancel = $("#projects .project i[id $='edit_cancel']").first()
    projects.findAllComponents('project')[0].editor.edit_cancel(edit_cancel) # cancel edit
    projects.findAllComponents('project')[0].editor.edit_start(edit_start) # start edit again
    expect($('.mandate input:checkbox').first().prop('checked')).to.be.true
    return

