test = (min,max,val)->
  media.findAllComponents('ma')[0]._between(min,max,val)
media_appearance_area_matches = ->
  _(media.findAllComponents('ma')).map (ma)-> ma._matches_area()
media_appearance_subarea_matches = ->
  _(media.findAllComponents('ma')).map (ma)-> ma._matches_subarea()
media_appearance_area_subarea_matches = ->
  _(media.findAllComponents('ma')).map (ma)-> ma._matches_area_subarea()

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


describe "area and subarea matching algorithm", ->
  before (done)->
    window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    MagicLamp.load("media_appearance_page") # that's the _index partial being loaded
    $.getScript "/assets/outreach_media.js", -> done()


#example:    media.set('media_appearances',[{"media_areas":[{"area_id":1,"subarea_ids":[1]},{"area_id":2,"subarea_ids":[8,9,10]}]}])

  it "should include media appearances matching any sort criteria areas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1},{"area_id":2}]},
                                      {"media_areas":[              {"area_id":2}]},
                                      {"media_areas":[{"area_id":1}              ]}
                                     ]})
    media.set({'sort_criteria.areas':[1,2], 'sort_criteria.rule':'any'})
    expect(media_appearance_area_matches()).to.eql [true,true,true]

  it "should include media appearances matching all sort criteria areas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1},{"area_id":2}]},
                                      {"media_areas":[              {"area_id":2}]},
                                      {"media_areas":[{"area_id":1}              ]}
                                     ]})
    media.set({'sort_criteria.areas':[1,2], 'sort_criteria.rule':'all'})
    expect(media_appearance_area_matches()).to.eql [true,false,false]

  it "should include media appearances matching any sort criteria subareas", ->
    media.reset({'media_appearances':[{"media_areas":[{"subarea_ids":[1]},{"subarea_ids":[10]}]},
                                      {"media_areas":[                    {"subarea_ids":[10]}]},
                                      {"media_areas":[{"subarea_ids":[1]}                      ]}
                                     ]})
    media.set({'sort_criteria.subareas':[1,10], 'sort_criteria.rule':'any'})
    expect(media_appearance_subarea_matches()).to.eql [true,true,true]

  it "should include media appearances matching all sort criteria subareas", ->
    media.reset({'media_appearances':[{"media_areas":[{"subarea_ids":[1]},{"subarea_ids":[10]}]},
                                      {"media_areas":[                    {"subarea_ids":[10]}]},
                                      {"media_areas":[{"subarea_ids":[1]}                     ]}
                                     ]})
    media.set({'sort_criteria.subareas':[1,10], 'sort_criteria.rule':'all'})
    expect(media_appearance_subarea_matches()).to.eql [true,false,false]

  it "should include media appearances matching any sort criteria areas and subareas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1, "subarea_ids":[1]}]},
                                      {"media_areas":[{             "subarea_ids":[1]}]} # implicit area 1, will preclude this scenario. There must always be an explicit area defined.
                                     ]})
    media.set({'sort_criteria.areas':[1], 'sort_criteria.rule':'any'})
    expect(media_appearance_area_matches()).to.eql [true,false] # decided to simplify and not test for implicit inclusion
    media.set({'sort_criteria.areas':[1], 'sort_criteria.rule':'all'})
    expect(media_appearance_area_matches()).to.eql [true,false] # decided to simplify and not test for implicit inclusion

  it "should include media appearances matching all sort criteria areas and subareas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1, "subarea_ids":[1]}, {"area_id":2, "subarea_ids":[8]}]},
                                      {"media_areas":[{"area_id":1, "subarea_ids":[1]}]}
                                      {"media_areas":[{"area_id":2, "subarea_ids":[8]}]}
                                      {"media_areas":[{"area_id":1                   }]}
                                      {"media_areas":[{"area_id":2                   }]}
                                     ]})
    media.set({'sort_criteria.areas':[1,2], 'sort_criteria.subareas':[1], 'sort_criteria.rule':'any'})
    expect(media_appearance_area_matches()).to.eql [true,true,true,true,true]

  it "should include media appearances matching any sort criteria areas and subareas2", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1, "subarea_ids":[1]}, {"area_id":2, "subarea_ids":[8]}]},
                                      {"media_areas":[{"area_id":1, "subarea_ids":[1]}]}
                                      {"media_areas":[{"area_id":2, "subarea_ids":[8]}]}
                                      {"media_areas":[{"area_id":1                   }]}
                                      {"media_areas":[{"area_id":2                   }]}
                                     ]})
    media.set({'sort_criteria.areas':[1,2], 'sort_criteria.subareas':[1], 'sort_criteria.rule':'any'})
    expect(media_appearance_area_subarea_matches()).to.eql [true,true,true,true,true]
    media.set({'sort_criteria.areas':[], 'sort_criteria.subareas':[], 'sort_criteria.rule':'any'})
    expect(media_appearance_area_subarea_matches()).to.eql [false,false,false,false,false]

  it "should include media appearances matching any sort criteria areas and subareas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1}]}]})
    media.set({'sort_criteria.areas':[2], 'sort_criteria.subareas':[], 'sort_criteria.rule':'any'})
    expect(media_appearance_area_subarea_matches()).to.eql [false]

  it "1should include media appearances matching  all sort criteria areas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1, "subarea_ids":[1]}, {"area_id":2, "subarea_ids":[8]}]}]})
    media.set({'sort_criteria.areas':[1,2], 'sort_criteria.subareas':[], 'sort_criteria.rule':'all'})
    expect(media_appearance_area_subarea_matches()).to.eql [true]

  it "should include media appearances matching   all sort criteria areas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1, "subarea_ids":[1]}]}]})
    media.set({'sort_criteria.areas':[1,2], 'sort_criteria.subareas':[1], 'sort_criteria.rule':'all'})
    expect(media_appearance_area_subarea_matches()).to.eql [false]

  it "2should include media appearances matching   all sort criteria areas", ->
    media.reset({'media_appearances':[{"media_areas":[{"area_id":1, "subarea_ids":[1]}]}]})
    media.set({'sort_criteria.areas':[1], 'sort_criteria.subareas':[], 'sort_criteria.rule':'all'})
    expect(media_appearance_area_subarea_matches()).to.eql [true]
    media.set({'sort_criteria.areas':[1], 'sort_criteria.subareas':[2], 'sort_criteria.rule':'all'})
    expect(media_appearance_area_subarea_matches()).to.eql [false]
