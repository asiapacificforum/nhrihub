test = (min,max,val)->
  media.findAllComponents('ma')[0]._between(min,max,val)


describe "within range evaluation", ->
  before (done)->
    window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    MagicLamp.load("media_appearance_page") # that's the _index partial being loaded
    $.getScript "/assets/outreach_media.js", -> done()

  it "should evaluate integers", ->
    min = 0
    max = 10
    val = 5
    expect(test(min,max,val)).to.be.true
    min = 0
    max = 5
    val = 10
    expect(test(min,max,val)).to.be.false

  it "should evaluate integers when range is indeterminate", ->
    min = NaN
    max = 10
    val = 5
    expect(test(min,max,val)).to.be.true
    min = NaN
    max = 5
    val = 10
    expect(test(min,max,val)).to.be.false
    min = NaN
    max = NaN
    val = 10
    expect(test(min,max,val)).to.be.true

  it "should evaluate indeterminate input as true", ->
    min = NaN
    max = NaN
    val = null
    expect(test(min,max,val)).to.be.true

  it "should evaluate floats", ->
    min = 0.5
    max = 5.3
    val = 2.5
    expect(test(min,max,val)).to.be.true
    min = 0.5
    max = 2.5
    val = 5.3
    expect(test(min,max,val)).to.be.false

  it "should evaluate floats when range is indeterminate", ->
    min = NaN
    max = 5.3
    val = 2.5
    expect(test(min,max,val)).to.be.true
    min = NaN
    max = 2.5
    val = 10.1
    expect(test(min,max,val)).to.be.false
    min = NaN
    max = NaN
    val = 10.4
    expect(test(min,max,val)).to.be.true

  it "should evaluate as true when min/max are empty", ->
    min = NaN
    max = NaN
    val = 4.4
    expect(test(min,max,val)).to.be.true

  it "should evaluate as true when val is empty", ->
    min = 2.3
    max = 8.7
    val = null
    expect(test(min,max,val)).to.be.true
