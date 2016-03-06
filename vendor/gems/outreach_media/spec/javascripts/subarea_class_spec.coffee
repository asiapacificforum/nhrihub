# it doesn't need to be run in the browser, but it's convenient to
# run all the js tests in the same environment
describe "Collection.Subarea class", ->
  before (done)->
    window.Collection = {}
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    $.getScript "/assets/media_issues_shared/subarea.js", ->
      done()

  it "creates a collection class", ->
    expect(Collection.Subarea.all().length).to.equal 10

  it "finds by id", ->
    expect(Collection.Subarea.find(1).name).to.equal "Violation"
    expect(Collection.Subarea.find(1).extended_name).to.equal "Human Rights Violation"

  it "finds by extended_name", ->
    expect(Collection.Subarea.find_by_extended_name("Human Rights Violation").id).to.equal 1
