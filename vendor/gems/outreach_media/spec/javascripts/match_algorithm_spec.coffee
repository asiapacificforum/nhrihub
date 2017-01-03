test = (min,max,val)->
  collection.findAllComponents('collectionItem')[0]._between(min,max,val)
media_appearance_area_matches = ->
  _(collection.findAllComponents('collectionItem')).map (ma)-> ma._matches_area()
media_appearance_subarea_matches = ->
  _(collection.findAllComponents('collectionItem')).map (ma)-> ma._matches_subarea()
media_appearance_area_subarea_matches = ->
  _(collection.findAllComponents('collectionItem')).map (ma)-> ma._matches_area_subarea()
media_appearance_affected_people_count_matches = ->
  _(collection.findAllComponents('collectionItem')).map (ma)-> ma._matches_people_affected()
media_appearance_violation_severity_matches = ->
  _(collection.findAllComponents('collectionItem')).map (ma)-> ma._matches_violation_severity()

log = (str)->
  re = new RegExp('phantomjs','gi')
  unless re.test navigator.userAgent
    console.log str

describe "within range evaluation", ->
  before (done)->
    window.Collection = {}
    window.collection_items = MagicLamp.loadJSON('collection_items')
    window.item_name = "media_appearance"
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    window.new_collection_item = MagicLamp.loadJSON('new_collection_item')
    window.create_collection_item_url = MagicLamp.loadRaw('create_collection_item_url')
    window.maximum_filesize = MagicLamp.loadJSON('maximum_filesize')
    window.permitted_filetypes = MagicLamp.loadJSON('permitted_filetypes')
    window.planned_results = []
    window.performance_indicators = []
    MagicLamp.load("media_appearance_page") # that's the _index partial being loaded
    $.getScript("/assets/media.js").
      done( -> 
        log "(within range evaluation) javascript was loaded"
        done()). # the collection_items.js app , start_page(), define_media
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

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
    val = parseInt(null)
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
    val = parseInt(null)
    expect(test(min,max,val)).to.be.true


describe "area and subarea matching algorithm", ->
  before (done)->
    window.Collection = {}
    window.collection_items = MagicLamp.loadJSON('collection_items')
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    window.new_collection_item = MagicLamp.loadJSON('new_collection_item')
    window.create_collection_item_url = MagicLamp.loadRaw('create_collection_item_url')
    window.maximum_filesize = MagicLamp.loadJSON('maximum_filesize')
    window.permitted_filetypes = MagicLamp.loadJSON('permitted_filetypes')
    window.planned_results = []
    window.performance_indicators = []
    MagicLamp.load("media_appearance_page") # that's the _index partial being loaded
    $.getScript("/assets/media.js").
      done( -> 
        log "(area and subarea matching algorithm) javascript was loaded"
        done()). # the collection_items.js app , start_page(), define_media
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

#example:    collection.set('collection_items',[{"media_areas":[{"area_id":1,"subarea_ids":[1]},{"area_id":2,"subarea_ids":[8,9,10]}]}])
  describe "match criteria for areas", ->
    it "should succeed when any of the sort criteria areas is matched", ->
      collection.reset({'collection_items':[ {"area_ids":[2], "media_areas":[{"area_id":2}]}]})
      collection.set({'filter_criteria.areas':[1,2]})
      expect(media_appearance_area_matches()).to.eql [true]

    it "should succeed when any of the sort criteria areas is matched, when subarea criteria are not specified", ->
      collection.reset({'collection_items':[{"area_ids":[1], "media_areas":[{"area_id":1, "subarea_ids":[1]}]}]})
      collection.set({'filter_criteria.areas':[1]})
      expect(media_appearance_area_matches()).to.eql [true]

    it "should fail when none of the sort criteria areas is matched, when subarea criteria are not specified", ->
      collection.reset({'collection_items':[ {"area_ids":[2], "subarea_ids":[8], "media_areas":[{"area_id":2, "subarea_ids":[8]}]}]})
      collection.set({'filter_criteria.areas':[1]})
      expect(media_appearance_area_matches()).to.eql [false]

    it "should succeed when any of the sort criteria areas or any of the sort criteria subareas is matched", ->
      collection.reset({'collection_items':[{"area_ids":[1,2], "subarea_ids":[1,8], "media_areas":[{"area_id":1, "subarea_ids":[1]}, {"area_id":2, "subarea_ids":[8]}]},
                                        {"area_ids":[1],   "subarea_ids":[1],   "media_areas":[{"area_id":1, "subarea_ids":[1]}]}
                                        {"area_ids":[2],   "subarea_ids":[8],   "media_areas":[{"area_id":2, "subarea_ids":[8]}]}
                                        {"area_ids":[1],   "subarea_ids":[],    "media_areas":[{"area_id":1                   }]}
                                        {"area_ids":[2],   "subarea_ids":[],    "media_areas":[{"area_id":2                   }]}
                                       ]})
      collection.set({'filter_criteria.areas':[1,2], 'filter_criteria.subareas':[1]})
      expect(media_appearance_area_matches()).to.eql [true,true,true,true,true]

    it "should succeed when areas attributes are empty", ->
      collection.reset({'collection_items':[ {"area_ids":[], "media_areas":[]}]})
      collection.set({'filter_criteria.areas':[1]})
      expect(media_appearance_area_matches()).to.eql [true]

  describe "match criteria for subareas", ->
    it "should include media appearances matching any sort criteria subareas", ->
      collection.reset({'collection_items':[ {"subarea_ids":[1], "media_areas":[{"subarea_ids":[1]}]}]})
      collection.set({'filter_criteria.subareas':[1,10]})
      expect(media_appearance_subarea_matches()).to.eql [true]

  describe "match criteria for areas and subareas", ->
    it "should succeed when any of the sort criteria areas or subareas is matched", ->
      collection.reset({'collection_items':[{"area_ids":[1,2], "media_areas":[{"area_id":1, "subarea_ids":[1]}, {"area_id":2, "subarea_ids":[8]}]},
                                        {"area_ids":[1],   "media_areas":[{"area_id":1, "subarea_ids":[1]}]}
                                        {"area_ids":[2],   "media_areas":[{"area_id":2, "subarea_ids":[8]}]}
                                        {"area_ids":[1],   "media_areas":[{"area_id":1                   }]}
                                        {"area_ids":[2],   "media_areas":[{"area_id":2                   }]}
                                       ]})
      collection.set({'filter_criteria.areas':[1,2], 'filter_criteria.subareas':[1]})
      expect(media_appearance_area_subarea_matches()).to.eql [true,true,true,true,true]

    it "should fail when filter_criteria areas and subareas are both empty", ->
      collection.reset({'collection_items':[{"area_ids":[1,2], "media_areas":[{"area_id":1, "subarea_ids":[1]}, {"area_id":2, "subarea_ids":[8]}]},
                                        {"area_ids":[1],   "media_areas":[{"area_id":1, "subarea_ids":[1]}]}
                                        {"area_ids":[2],   "media_areas":[{"area_id":2, "subarea_ids":[8]}]}
                                        {"area_ids":[1],   "media_areas":[{"area_id":1                   }]}
                                        {"area_ids":[2],   "media_areas":[{"area_id":2                   }]}
                                       ]})
      collection.set({'filter_criteria.areas':[], 'filter_criteria.subareas':[]})
      expect(media_appearance_area_subarea_matches()).to.eql [false,false,false,false,false]

    it "should fail when sort criteria areas is not matched", ->
      collection.reset({'collection_items':[{"area_ids":[1], "media_areas":[{"area_id":1}]}]})
      collection.set({'filter_criteria.areas':[2], 'filter_criteria.subareas':[]})
      expect(media_appearance_area_subarea_matches()).to.eql [false]

  describe "matching of human rights-specific parameters", ->
    describe "when instance is not human rights violation", ->
      it "should ignore any value in the people affected criteria and interpret it as zero", ->
        collection.set({'collection_items': [{'title':'foo','media_appearance_areas':[{'area_id':1, 'subarea_ids':[2]}],'metrics':{'affected_people_count':{'value':23}}}]})
        collection.set({'filter_criteria.pa_min':0, 'filter_criteria.pa_max':30})
        expect(media_appearance_affected_people_count_matches()).to.eql [true]
        collection.set({'filter_criteria.pa_min':8, 'filter_criteria.pa_max':30})
        expect(media_appearance_affected_people_count_matches()).to.eql [false]

    describe "when instance is human rights violation", ->
      describe "and affected_people_count parameter value falls outside thresholds", ->
        it "should exclude the instance", ->
          collection.set({'collection_items': [{'title':'bar','media_appearance_areas':[{'area_id':1, 'subarea_ids':[1]}],'metrics':{'affected_people_count':{'value':23}}}]})
          collection.set({'filter_criteria.pa_min':8, 'filter_criteria.pa_max':20})
          expect(media_appearance_affected_people_count_matches()).to.eql [false]

      describe "and affected_people_count parameter value is null", ->
        it "should interpret the null value as zero", ->
          collection.set({'collection_items': [{'title':'baz', 'media_appearance_areas':[{'area_id':1, 'subarea_ids':[1]}], 'metrics':{'affected_people_count':{'value':null}}}]})
          collection.set({'filter_criteria.pa_min':0, 'filter_criteria.pa_max':20})
          expect(media_appearance_affected_people_count_matches()).to.eql [true]
          collection.set({'filter_criteria.pa_min':8, 'filter_criteria.pa_max':20})
          expect(media_appearance_affected_people_count_matches()).to.eql [false]
