MediaPage = ->
  text_fields : ->
    _($('.media_appearance .basic_info .title:visible','.magic-lamp')).
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
  click_crc_subarea : ->
    simulant.fire(@hr_crc_link(),'click')

sort_criteria =
  title : -> media.get('sort_criteria.title')
  areas : -> media.get('sort_criteria.areas')
  subareas : -> media.get('sort_criteria.subareas')
  from : -> media.get('sort_criteria.from').getTime()
  to : -> media.get('sort_criteria.to').getTime()

describe 'Media page', ->
  beforeEach (done)->
    window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    MagicLamp.load("media_appearance_page") # that's the _index partial being loaded
    @page = new MediaPage()
    $.getScript "/assets/outreach_media.js", -> done()

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
    expect(sort_criteria.title()).to.equal 'F'
    expect($('#sort_criteria #title').text()).to.equal 'F'

  it 'filters media appearances by earliest date', ->
    @page.set_from_date('08/19/2014')
    expect(sort_criteria.from()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 1
    expect(@page.text_fields()).to.include "Fantasy land"

  it 'filters media appearances by latest date', ->
    @page.set_to_date('08/19/2014')
    expect(sort_criteria.to()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 7
    expect(@page.text_fields()).to.not.include "Fantasy land"

  it 'filters media appearances by area', ->
    @page.open_area_dropdown()
    human_rights_select = @page.$area().find('.area a')[0]
    human_rights_id = (_(areas).detect (a)->a.name == "Human Rights").id
    simulant.fire(human_rights_select,'click')
    expect(sort_criteria.areas()).to.eql [human_rights_id]
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    simulant.fire(human_rights_select,'click')
    expect(sort_criteria.areas()).to.eql []
    expect(@page.text_fields_length()).to.equal 8

  it 'filters media appearances by subarea returns matching subareas', ->
    @page.open_area_dropdown()
    crc_id = (_(subareas).detect (sa)-> sa.name == "CRC").id
    @page.click_crc_subarea()
    expect(sort_criteria.subareas()).to.eql [crc_id]
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    @page.click_crc_subarea()
    expect(sort_criteria.areas()).to.eql []
    expect(@page.text_fields_length()).to.equal 8

  it 'filters media appearances by violation coefficient', ->
    # pending

  it 'shows error message when invalid validation coefficient values are entered',->
    # pending
    # error message is cleared when new input is started

  it 'filters media appearances by positivity rating', ->
    # pending

  it 'shows error message when invalid positivity rating values are entered',->
    # pending
    # error message is cleared when new input is started

  it 'filters media appearances by violation severity', ->
    # pending

  it 'shows error message when invalid violation severity values are entered',->
    # pending
    # error message is cleared when new input is started

  it 'filters media appearances by # people affected', ->
    # pending

  it 'shows error message when invalid # people values are entered',->
    # pending
    # error message is cleared when new input is started

  it 'clears all filter parameters when clear button is clicked', ->
    # pending

  it 'shows warning when invalid date is manually entered', ->
    # pending

  it 'shows no matches message when there are no matches', ->
    # pending

  it 'shows a summary of the filter criteria', ->
    # pending
