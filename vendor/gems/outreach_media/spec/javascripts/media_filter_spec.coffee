AdvisoryCouncilIssuePage = ->
  new_advisory_council_issue : ->
    aci =
        id: null
        file_id: null
        filesize: null
        original_filename: null
        original_type: null
        user_id: null
        url: null
        title: null
        positivity_rating_id: null
        violation_severity_id: null
        lastModifiedDate: null
        article_link: null
        date: null
        positivity_rating: null
        violation_severity: null
        violation_coefficient: null
        affected_people_count: null
        has_link: false
        has_scanned_doc: false
        media_areas: []
        area_ids: []
        subarea_ids: []
        reminders: []
        notes: []
        create_reminder_url: null
        create_note_url: null

    _.extend({},aci)

MediaPage = ->
  new_media_appearance : ->
    ma =
        id: null
        file_id: null
        filesize: null
        original_filename: null
        original_type: null
        user_id: null
        url: null
        title: null
        positivity_rating_id: null
        violation_severity_id: null
        lastModifiedDate: null
        article_link: null
        date: null
        positivity_rating: null
        violation_severity: null
        violation_coefficient: null
        affected_people_count: null
        has_link: false
        has_scanned_doc: false
        media_areas: []
        area_ids: []
        subarea_ids: []
        performance_indicator_ids: []
        reminders: []
        notes: []
        create_reminder_url: null
        create_note_url: null

    _.extend({},ma)

  text_fields : ->
    _($('.media_appearance .basic_info .title:visible .no_edit span','.magic-lamp')).
      map (el)-> $(el).text()
  text_fields_length : -> @text_fields().length
  $media_appearance_controls : -> $('#media_appearances_controls')
  $title_input : -> @$media_appearance_controls().find('input#title')
  $date_from : -> @$media_appearance_controls().find('input#from')
  $date_to : -> @$media_appearance_controls().find('input#to')
  $area : -> @$media_appearance_controls().find('.area-select')
  set_from_date : (date_str)->
    @$date_from().datepicker('show')
    @$date_from().datepicker('setDate',date_str)
    @$date_from().datepicker('hide')
  set_to_date : (date_str)->
    @$date_to().datepicker('show')
    @$date_to().datepicker('setDate',date_str)
    @$date_to().datepicker('hide')
  human_rights_crc_li : ->
    _($('.area-select .subarea')).select (el)->
      re = new RegExp(/CRC/)
      re.test($(el).text())
  hr_crc_link : -> $(@human_rights_crc_li()).find('a')[0]
  open_area_dropdown : ->
    @$area().find('.dropdown-toggle').click()
  unselect_area_subarea : ->
    _(collection.findAllComponents('area')).each (a)-> a.unselect()
    _(collection.findAllComponents('subarea')).each (a)-> a.unselect()
  click_crc_subarea : ->
    simulant.fire(@hr_crc_link(),'click')
  violation_coefficient : (minmax)->
    $(".vc_#{minmax} input")
  positivity_rating : (minmax)->
    $(".pr_#{minmax} input")
  violation_severity : (minmax)->
    $(".vs_#{minmax} input")
  people_affected : (minmax)->
    $(".pa_#{minmax} input")
  vc_min : ->
    $(".filter_field.vc_min")
  vc_max : ->
    $(".filter_field.vc_max")
  pr_min : ->
    $(".filter_field.pr_min")
  pr_max : ->
    $(".filter_field.pr_max")
  vs_min : ->
    $(".filter_field.vs_min")
  vs_max : ->
    $(".filter_field.vs_max")
  pa_min : ->
    $(".filter_field.pa_min")
  pa_max : ->
    $(".filter_field.pa_max")

filter_criteria =
  title : -> collection.get('filter_criteria.title')
  areas : -> collection.get('filter_criteria.areas')
  subareas : -> collection.get('filter_criteria.subareas')
  from : -> collection.get('filter_criteria.from').getTime()
  to : -> collection.get('filter_criteria.to').getTime()
  vc_min : -> collection.get('filter_criteria.vc_min')
  vc_max : -> collection.get('filter_criteria.vc_max')
  pr_min : -> collection.get('filter_criteria.pr_min')
  pr_max : -> collection.get('filter_criteria.pr_max')
  vs_min : -> collection.get('filter_criteria.vs_min')
  vs_max : -> collection.get('filter_criteria.vs_max')
  pa_min : -> collection.get('filter_criteria.pa_min')
  pa_max : -> collection.get('filter_criteria.pa_max')
  reset_areas_subareas : ->
    collection.set('filter_criteria.areas',[])
    collection.set('filter_criteria.subareas',[])

log = (str)->
  re = new RegExp('phantomjs','gi')
  ua = navigator.userAgent
  unless re.test ua
    console.log str

describe 'media filter', ->
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
    @page = new MediaPage()
    $.getScript("/assets/media.js").
      done( ->
        log "(Media page) javascript was loaded"
        done()). # the media_appearances.js app , start_page(), define_media
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

  beforeEach ->
    collection.set_defaults()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Media Archive"
    expect($(".media_appearance", '.magic-lamp').length).to.equal 8
    expect(typeof(simulant)).to.not.equal("undefined")

  it 'filters media appearances by title',->
    expect(@page.text_fields_length()).to.equal 8
    @page.$title_input().val('F')
    simulant.fire(@page.$title_input()[0],'change')
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    expect(filter_criteria.title()).to.equal 'F'

  it 'filters media appearances by earliest date', ->
    @page.set_from_date('19/08/2014')
    expect(filter_criteria.from()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 1
    expect(@page.text_fields()).to.include "Fantasy land"

  it 'filters media appearances by latest date', ->
    @page.set_to_date('19/08/2014')
    expect(filter_criteria.to()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 7
    expect(@page.text_fields()).to.not.include "Fantasy land"

  it 'filters media appearances by area', ->
    @page.unselect_area_subarea()
    @page.open_area_dropdown()
    human_rights_select = @page.$area().find('.area a')[0]
    human_rights_id = (_(areas).detect (a)->a.name == "Human Rights").id
    simulant.fire(human_rights_select,'click')
    expect(filter_criteria.areas()).to.eql [human_rights_id]
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    simulant.fire(human_rights_select,'click')
    expect(filter_criteria.areas()).to.eql []
    expect(@page.text_fields_length()).to.equal 0

  it 'filters media appearances by subarea returns matching subareas', ->
    @page.unselect_area_subarea()
    @page.open_area_dropdown()
    crc_id = (_(subareas).detect (sa)-> sa.name == "CRC").id
    @page.click_crc_subarea()
    expect(filter_criteria.subareas()).to.eql [crc_id]
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    @page.click_crc_subarea()
    expect(filter_criteria.areas()).to.eql []
    expect(@page.text_fields_length()).to.equal 0

  it 'filters media appearances by violation coefficient', ->
    # only applies to hr_violation, all non-hr_violation instances have violation_coefficient set to 0
    # so they're included if vc_min is 0 and not included if vc_min > 0
    expect(@page.text_fields_length()).to.equal 8
    @page.violation_coefficient('min').val(0.2)
    simulant.fire(@page.violation_coefficient('min')[0],'change')
    @page.violation_coefficient('max').val(10.1)
    simulant.fire(@page.violation_coefficient('max')[0],'change')
    expect(filter_criteria.vc_min()).to.equal "0.2" # all non-hr_violation excluded
    expect(filter_criteria.vc_max()).to.equal "10.1"
    expect(@page.text_fields_length()).to.equal 2
    @page.violation_coefficient('max').val(5)
    simulant.fire(@page.violation_coefficient('max')[0],'change')
    expect(@page.text_fields_length()).to.equal 1

  it 'shows error message when invalid minimum validation coefficient values are entered',->
    @page.violation_coefficient('min').val('A')
    simulant.fire(@page.violation_coefficient('min')[0],'change')
    expect(@page.vc_min()).to.have.$class('error')
    @page.violation_coefficient('min').val('')
    simulant.fire(@page.violation_coefficient('min')[0],'change')
    expect(@page.vc_min()).to.not.have.$class('error')
    @page.violation_coefficient('min').val('2')
    simulant.fire(@page.violation_coefficient('min')[0],'change')
    expect(@page.vc_min()).to.not.have.$class('error')

  it 'shows error message when invalid max validation coefficient values are entered',->
    @page.violation_coefficient('max').val('A')
    simulant.fire(@page.violation_coefficient('max')[0],'change')
    expect(@page.vc_max()).to.have.$class('error')
    @page.violation_coefficient('max').val('')
    simulant.fire(@page.violation_coefficient('max')[0],'change')
    expect(@page.vc_max()).to.not.have.$class('error')
    @page.violation_coefficient('max').val('2')
    simulant.fire(@page.violation_coefficient('max')[0],'change')
    expect(@page.vc_max()).to.not.have.$class('error')

  it 'filters media appearances by positivity rating', ->
    @page.positivity_rating('min').val(4)
    simulant.fire(@page.positivity_rating('min')[0],'change')
    @page.positivity_rating('max').val(6)
    simulant.fire(@page.positivity_rating('max')[0],'change')
    expect(filter_criteria.pr_min()).to.equal "4"
    expect(filter_criteria.pr_max()).to.equal "6"
    expect(@page.text_fields_length()).to.equal 1

  it 'shows error message when invalid min positivity rating values are entered',->
    @page.positivity_rating('min').val('A')
    simulant.fire(@page.positivity_rating('min')[0],'change')
    expect(@page.pr_min()).to.have.$class('error')
    @page.positivity_rating('min').val('')
    simulant.fire(@page.positivity_rating('min')[0],'change')
    expect(@page.pr_min()).to.not.have.$class('error')
    @page.positivity_rating('min').val('2')
    simulant.fire(@page.positivity_rating('min')[0],'change')
    expect(@page.pr_min()).to.not.have.$class('error')

  it 'shows error message when invalid max positivity rating values are entered',->
    @page.positivity_rating('max').val('A')
    simulant.fire(@page.positivity_rating('max')[0],'change')
    expect(@page.pr_max()).to.have.$class('error')
    @page.positivity_rating('max').val('')
    simulant.fire(@page.positivity_rating('max')[0],'change')
    expect(@page.pr_max()).to.not.have.$class('error')
    @page.positivity_rating('max').val('2')
    simulant.fire(@page.positivity_rating('max')[0],'change')
    expect(@page.pr_max()).to.not.have.$class('error')

  it 'filters media appearances by violation severity', ->
    @page.violation_severity('min').val(4)
    simulant.fire(@page.violation_severity('min')[0],'change')
    @page.violation_severity('max').val(6)
    simulant.fire(@page.violation_severity('max')[0],'change')
    expect(filter_criteria.vs_min()).to.equal "4"
    expect(filter_criteria.vs_max()).to.equal "6"
    expect(@page.text_fields_length()).to.equal 1

  it 'shows error message when invalid minimum violation severity values are entered',->
    @page.violation_severity('min').val('A')
    simulant.fire(@page.violation_severity('min')[0],'change')
    expect(@page.vs_min()).to.have.$class('error')
    @page.violation_severity('min').val('')
    simulant.fire(@page.violation_severity('min')[0],'change')
    expect(@page.vs_min()).to.not.have.$class('error')
    @page.violation_severity('min').val('2')
    simulant.fire(@page.violation_severity('min')[0],'change')
    expect(@page.vs_min()).to.not.have.$class('error')

  it 'shows error message when invalid maximum violation severity values are entered',->
    @page.violation_severity('max').val('A')
    simulant.fire(@page.violation_severity('max')[0],'change')
    expect(@page.vs_max()).to.have.$class('error')
    @page.violation_severity('max').val('')
    simulant.fire(@page.violation_severity('max')[0],'change')
    expect(@page.vs_max()).to.not.have.$class('error')
    @page.violation_severity('max').val('2')
    simulant.fire(@page.violation_severity('max')[0],'change')
    expect(@page.vs_max()).to.not.have.$class('error')

  it 'filters media appearances by # people affected', ->
    @page.people_affected('min').val(444)
    simulant.fire(@page.people_affected('min')[0],'change')
    @page.people_affected('max').val(4000)
    simulant.fire(@page.people_affected('max')[0],'change')
    expect(filter_criteria.pa_min()).to.equal "444"
    expect(filter_criteria.pa_max()).to.equal "4000"
    # one hr_violation instance matches, one hr_violation instance doesn't match, and all 6 not hr_violation are automatically excluded
    expect(@page.text_fields_length()).to.equal 1

  it 'shows error message when invalid minimum # people values are entered',->
    @page.people_affected('min').val('A')
    simulant.fire(@page.people_affected('min')[0],'change')
    expect(@page.pa_min()).to.have.$class('error')
    @page.people_affected('min').val('')
    simulant.fire(@page.people_affected('min')[0],'change')
    expect(@page.pa_min()).to.not.have.$class('error')
    @page.people_affected('min').val('2')
    simulant.fire(@page.people_affected('min')[0],'change')
    expect(@page.pa_min()).to.not.have.$class('error')

  it 'shows error message when invalid maximum # people values are entered',->
    @page.people_affected('max').val('A')
    simulant.fire(@page.people_affected('max')[0],'change')
    expect(@page.pa_max()).to.have.$class('error')
    @page.people_affected('max').val('')
    simulant.fire(@page.people_affected('max')[0],'change')
    expect(@page.pa_max()).to.not.have.$class('error')
    @page.people_affected('max').val('2')
    simulant.fire(@page.people_affected('max')[0],'change')
    expect(@page.pa_max()).to.not.have.$class('error')


  #it 'clears all filter parameters when clear button is clicked', ->
    # pending

  it 'shows no matches message when there are no matches', ->
    # pending

  it 'initializes the filter parameters with the lowest and highest actual values', ->
    expect(@page.$date_from().val()).to.equal '01/01/2014'
    expect(@page.$date_to().val()).to.equal '01/01/2015'
    expect(@page.violation_coefficient('min').val()).to.equal '0'
    expect(@page.violation_coefficient('max').val()).to.equal '10'
    expect(@page.positivity_rating('min').val()).to.equal '1'
    expect(@page.positivity_rating('max').val()).to.equal '5'
    expect(@page.violation_severity('min').val()).to.equal '0'
    expect(@page.violation_severity('max').val()).to.equal '5'
    expect(@page.people_affected('min').val()).to.equal '0'
    expect(@page.people_affected('max').val()).to.equal '555' #b/c all the non-hr_violation values were set to zero

  it 'renders new media_appearance form even if entered values are outside filter range', ->
    ma1 = _.extend({}, @page.new_media_appearance())

    ma2 = _.extend(@page.new_media_appearance(), {
                                            title: "bar",
                                            id : 44,
                                            affected_people_count : 15,
                                            area_ids : [1],
                                            subarea_ids : [1]})

    ma3 = _.extend(@page.new_media_appearance(), {
                                            title: "baz",
                                            id : 48,
                                            affected_people_count : 23 ,
                                            area_ids : [1],
                                            subarea_ids : [1]})


    collection.set({'collection_items': [ma1,ma2,ma3]})
    collection.populate_min_max_fields()
    expect($('.media_appearance:visible').length).to.equal 3
    expect(collection.get('filter_criteria.pa_min')).to.equal 0 # due to the new_media_appearance
    expect(collection.get('filter_criteria.pa_max')).to.equal 23
    collection.findAllComponents('collectionItem')[0].set('metrics.affected_people_count.value',30)
    expect($('.media_appearance:visible').length).to.equal 3
    collection.findAllComponents('collectionItem')[1].set('editing',true)
    collection.findAllComponents('collectionItem')[1].set('metrics.affected_people_count.value',40)
    expect($('.media_appearance:visible').length).to.equal 3


describe 'media_appearance attachment validation', ->
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
    @page = new MediaPage()
    $.getScript("/assets/media.js").
      done( ->
        log "(Media page) javascript was loaded"
        done()). # the media_appearances.js app , start_page(), define_media
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

  beforeEach ->
    collection.set_defaults()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Media Archive"
    expect($(".media_appearance", '.magic-lamp').length).to.equal 8
    expect(typeof(simulant)).to.not.equal("undefined")

  it 'validates unpersisted media_appearance with valid attachment and no link', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:5000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'validates persisted media_appearance with no attachment, an origina_filename, and no link', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf"
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'validates unpersisted media_appearance with link and no attachment', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'validates persisted media_appearance with link and no attachment', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'does not validate unpersisted media_appearance with both link and attachment', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:5000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('collection_item_double_attachment_error')).to.equal true

  it 'does not validate persisted media_appearance with both link and attachment', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:5000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('collection_item_double_attachment_error')).to.equal true

  it 'does not validate persisted media_appearance with a link and no attachment but with an original_filename', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                            original_filename : "some_file_name.pdf" })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('collection_item_double_attachment_error')).to.equal true

  it 'does not validate unpersisted media_appearance with no link and no attachment', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : null, # unpersisted!
                                            title: "bar"
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('collection_item_error')).to.equal true

  it 'does not validate persisted media_appearance with no link and no attachment', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : 44, # persisted!
                                            title: "bar"
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('collection_item_error')).to.equal true

  it 'does not validate attachment which is too big', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:50000000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('filesize_error')).to.equal true

  it 'does not validate attachment of an unpermitted type', ->
    media_appearance = _.extend(@page.new_media_appearance(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:500000,name:"filename.xyz"}]},
                                           })
    collection.set({'collection_items': [media_appearance]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('filetype_error')).to.equal true

describe 'advisory_council_issue attachment validation', ->
  before (done)->
    window.Collection = {}
    #window.collection_items = MagicLamp.loadJSON('advisory_council_issues')
    window.collection_items = []
    window.item_name = "advisory_council_issue"
    #window.areas = MagicLamp.loadJSON('areas_data')
    window.areas = []
    #window.subareas = MagicLamp.loadJSON('subareas_data')
    #window.new_collection_item = MagicLamp.loadJSON('new_advisory_council_issue_collection_item')
    #window.create_collection_item_url = MagicLamp.loadRaw('create_advisory_council_issue_collection_item_url')
    window.create_collection_item_url = ""
    window.maximum_filesize = MagicLamp.loadJSON('maximum_filesize')
    window.permitted_filetypes = MagicLamp.loadJSON('permitted_filetypes')
    window.planned_results = []
    window.performance_indicators = []
    MagicLamp.load("advisory_council_issues_page") # that's the _index partial being loaded
    @page = new AdvisoryCouncilIssuePage()
    $.getScript("/assets/issues.js").
      done( ->
        log "(Advisory council issues) javascript was loaded"
        done()). # the media_appearances.js app , start_page(), define_media
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

  beforeEach ->
    collection.set_defaults()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Issues"
    expect(typeof(simulant)).to.not.equal("undefined")

  it 'validates unpersisted advisory_council_issue with valid attachment and no link', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:5000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'validates persisted advisory_council_issue with no attachment, an origina_filename, and no link', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf"
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'validates unpersisted advisory_council_issue with link and no attachment', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'validates persisted advisory_council_issue with link and no attachment', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true

  it 'validates unpersisted advisory_council_issue with both link and attachment', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:5000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true
    expect(collection.findComponent('collectionItem').get('collection_item_double_attachment_error')).to.equal false

  it 'validates persisted advisory_council_issue with both link and attachment', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:5000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true
    expect(collection.findComponent('collectionItem').get('collection_item_double_attachment_error')).to.equal false

  it 'validates persisted advisory_council_issue with a link and no attachment but with an original_filename', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : 44, # persisted!
                                            title: "bar",
                                            article_link : "www.foo.bar",
                                            original_filename : "some_file_name.pdf" })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true
    expect(collection.findComponent('collectionItem').get('collection_item_double_attachment_error')).to.equal false

  # problem test
  it 'validates unpersisted advisory_council_issue with no link and no attachment', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : null, # unpersisted!
                                            title: "bar"
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true
    expect(collection.findComponent('collectionItem').get('collection_item_error')).to.equal false

  # problem test
  it 'validates persisted advisory_council_issue with no link and no attachment', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : 44, # persisted!
                                            title: "bar"
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal true
    expect(collection.findComponent('collectionItem').get('collection_item_error')).to.equal false

  it 'does not validate attachment which is too big', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:50000000,name:"filename.pdf"}]},
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('filesize_error')).to.equal true

  it 'does not validate attachment of an unpermitted type', ->
    advisory_council_issue = _.extend(@page.new_advisory_council_issue(), {
                                            id : null, # unpersisted!
                                            title: "bar",
                                            original_filename : "some_file_name.pdf",
                                            fileupload : {files:[{size:500000,name:"filename.xyz"}]},
                                           })
    collection.set({'collection_items': [advisory_council_issue]})
    expect(collection.findComponent('collectionItem').validate()).to.equal false
    expect(collection.findComponent('collectionItem').get('filetype_error')).to.equal true
