MediaPage = ->
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
    _(media.findAllComponents('area')).each (a)-> a.unselect()
    _(media.findAllComponents('subarea')).each (a)-> a.unselect()
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

sort_criteria =
  title : -> media.get('sort_criteria.title')
  areas : -> media.get('sort_criteria.areas')
  subareas : -> media.get('sort_criteria.subareas')
  from : -> media.get('sort_criteria.from').getTime()
  to : -> media.get('sort_criteria.to').getTime()
  vc_min : -> media.get('sort_criteria.vc_min')
  vc_max : -> media.get('sort_criteria.vc_max')
  pr_min : -> media.get('sort_criteria.pr_min')
  pr_max : -> media.get('sort_criteria.pr_max')
  vs_min : -> media.get('sort_criteria.vs_min')
  vs_max : -> media.get('sort_criteria.vs_max')
  pa_min : -> media.get('sort_criteria.pa_min')
  pa_max : -> media.get('sort_criteria.pa_max')
  reset_areas_subareas : ->
    media.set('sort_criteria.areas',[])
    media.set('sort_criteria.subareas',[])

describe 'Media page', ->
  before (done)->
    window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    window.new_media_appearance = MagicLamp.loadJSON('new_media_appearance')
    window.create_media_appearance_url = MagicLamp.loadRaw('create_media_appearance_url')
    MagicLamp.load("media_appearance_page") # that's the _index partial being loaded
    @page = new MediaPage()
    $.getScript "/assets/media.js", -> done()

  beforeEach ->
    media.set_defaults()

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

  it 'filters media appearances by earliest date', ->
    @page.set_from_date('19/08/2014')
    expect(sort_criteria.from()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 1
    expect(@page.text_fields()).to.include "Fantasy land"

  it 'filters media appearances by latest date', ->
    @page.set_to_date('19/08/2014')
    expect(sort_criteria.to()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 7
    expect(@page.text_fields()).to.not.include "Fantasy land"

  it 'filters media appearances by area', ->
    @page.unselect_area_subarea()
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
    expect(@page.text_fields_length()).to.equal 0

  it 'filters media appearances by subarea returns matching subareas', ->
    @page.unselect_area_subarea()
    @page.open_area_dropdown()
    crc_id = (_(subareas).detect (sa)-> sa.name == "CRC").id
    @page.click_crc_subarea()
    expect(sort_criteria.subareas()).to.eql [crc_id]
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    @page.click_crc_subarea()
    expect(sort_criteria.areas()).to.eql []
    expect(@page.text_fields_length()).to.equal 0

  it 'filters media appearances by violation coefficient', ->
    @page.violation_coefficient('min').val(0.2)
    simulant.fire(@page.violation_coefficient('min')[0],'change')
    @page.violation_coefficient('max').val(0.8)
    simulant.fire(@page.violation_coefficient('max')[0],'change')
    expect(sort_criteria.vc_min()).to.equal "0.2"
    expect(sort_criteria.vc_max()).to.equal "0.8"
    expect(@page.text_fields_length()).to.equal 1
    @page.violation_coefficient('max').val(20)
    simulant.fire(@page.violation_coefficient('max')[0],'change')
    expect(@page.text_fields_length()).to.equal 8

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
    expect(sort_criteria.pr_min()).to.equal "4"
    expect(sort_criteria.pr_max()).to.equal "6"
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
    expect(sort_criteria.vs_min()).to.equal "4"
    expect(sort_criteria.vs_max()).to.equal "6"
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
    @page.people_affected('max').val(6000000)
    simulant.fire(@page.people_affected('max')[0],'change')
    expect(sort_criteria.pa_min()).to.equal "444"
    expect(sort_criteria.pa_max()).to.equal "6000000"
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
    expect(@page.violation_coefficient('min').val()).to.equal '0.7'
    expect(@page.violation_coefficient('max').val()).to.equal '10'
    expect(@page.positivity_rating('min').val()).to.equal '2'
    expect(@page.positivity_rating('max').val()).to.equal '9'
    expect(@page.violation_severity('min').val()).to.equal '2'
    expect(@page.violation_severity('max').val()).to.equal '9'
    expect(@page.people_affected('min').val()).to.equal '555'
    expect(@page.people_affected('max').val()).to.equal '55500000'
