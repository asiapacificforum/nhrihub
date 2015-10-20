describe 'ractive file uploader', ->
  before (done)->
    window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    window.new_media_appearance = MagicLamp.loadJSON('new_media_appearance')
    window.create_media_appearance_url = MagicLamp.loadRaw('create_media_appearance_url')
    MagicLamp.load("media_appearance_page") # that's the _index partial being loaded
    #@page = new MediaPage()
    $.getScript "/assets/outreach_media.js", -> done()

  beforeEach ->
    media.set_defaults()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Media Archive"
    expect($(".media_appearance", '.magic-lamp').length).to.equal 8
    expect(typeof(simulant)).to.not.equal("undefined")
