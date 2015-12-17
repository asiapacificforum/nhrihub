OutreachPage = ->
  text_fields : ->
    _($('.outreach_event .basic_info .title:visible .no_edit span','.magic-lamp')).
      map (el)-> $(el).text()
  text_fields_length : -> @text_fields().length
  $outreach_event_controls : -> $('#outreach_events_controls')
  $title_input : -> @$outreach_event_controls().find('input#title')
  $audience_name_input : -> @$outreach_event_controls().find('input.audience_name')
  $date_from : -> @$outreach_event_controls().find('input#from')
  $date_to : -> @$outreach_event_controls().find('input#to')
  $area : -> @$outreach_event_controls().find('.area-select')
  select_audience_type : (text)->
    $(".audience_type-select .audience_type .text:contains('#{text}')").closest('a.opt').find('.fa-check').click()
  select_impact_rating : (text)->
    $(".impact_rating-select .impact_rating .text:contains('#{text}')").closest('a.opt').find('.fa-check').click()
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
  open_audience_type_dropdown : ->
    $('.audience_type-select').find('.dropdown-toggle').click()
  open_area_dropdown : ->
    @$area().find('.dropdown-toggle').click()
  open_impact_rating_dropdown : ->
    $('.impact_rating-select').find('.dropdown-toggle').click()
  unselect_area_subarea : ->
    _(outreach.findAllComponents('area')).each (a)-> a.unselect()
    _(outreach.findAllComponents('subarea')).each (a)-> a.unselect()
  click_crc_subarea : ->
    simulant.fire(@hr_crc_link(),'click')
  #violation_coefficient : (minmax)->
    #$(".vc_#{minmax} input")
  #positivity_rating : (minmax)->
    #$(".pr_#{minmax} input")
  #violation_severity : (minmax)->
    #$(".vs_#{minmax} input")
  people_affected : (minmax)->
    $(".pa_#{minmax} input")
  participants : (minmax)->
    $(".pp_#{minmax} input")
  impact_rating : (minmax)->
    $(".ir_#{minmax} input")
  #vc_min : ->
    #$(".filter_field.vc_min")
  #vc_max : ->
    #$(".filter_field.vc_max")
  #pr_min : ->
    #$(".filter_field.pr_min")
  #pr_max : ->
    #$(".filter_field.pr_max")
  #vs_min : ->
    #$(".filter_field.vs_min")
  #vs_max : ->
    #$(".filter_field.vs_max")
  pa_min : ->
    $(".filter_field.pa_min")
  pa_max : ->
    $(".filter_field.pa_max")
  pp_min : ->
    $(".filter_field.pp_min")
  pp_max : ->
    $(".filter_field.pa_max")

filter_criteria =
  title : -> outreach.get('filter_criteria.title')
  areas : -> outreach.get('filter_criteria.areas')
  subareas : -> outreach.get('filter_criteria.subareas')
  from : -> outreach.get('filter_criteria.from').getTime()
  to : -> outreach.get('filter_criteria.to').getTime()
  pa_min : -> outreach.get('filter_criteria.pa_min')
  pa_max : -> outreach.get('filter_criteria.pa_max')
  pp_min : -> outreach.get('filter_criteria.pp_min')
  pp_max : -> outreach.get('filter_criteria.pp_max')
  selected_audience_type_id : null
  reset_areas_subareas : ->
    outreach.set('filter_criteria.areas',[])
    outreach.set('filter_criteria.subareas',[])

describe 'Outreach page', ->
  before (done)->
    window.outreach_events = MagicLamp.loadJSON('outreach_event_data')
    window.areas = MagicLamp.loadJSON('areas_data')
    window.subareas = MagicLamp.loadJSON('subareas_data')
    window.new_outreach_event = MagicLamp.loadJSON('new_outreach_event')
    window.create_outreach_event_url = MagicLamp.loadRaw('create_outreach_event_url')
    window.maximum_filesize = MagicLamp.loadJSON('maximum_filesize')
    window.permitted_filetypes = MagicLamp.loadJSON('permitted_filetypes')
    window.default_selected_audience_type = MagicLamp.loadRaw('selected_audience_type')
    window.audience_types = MagicLamp.loadJSON('audience_types')
    window.default_selected_impact_rating = MagicLamp.loadRaw('selected_impact_rating')
    window.impact_ratings = MagicLamp.loadJSON('impact_ratings')
    MagicLamp.load("outreach_event_page") # that's the _index partial being loaded
    @page = new OutreachPage()
    $.getScript("/assets/outreach.js").
      done( -> 
        console.log "(Outreach page) javascript was loaded"
        done()). # the outreach_events.js app , start_page(), define outreach
      fail( (jqxhr, settings, exception) ->
        console.log "Triggered ajaxError handler"
        console.log settings
        console.log exception)

  beforeEach ->
    outreach.set_defaults()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Outreach Events"
    expect($(".outreach_event", '.magic-lamp').length).to.equal 8
    expect(typeof(simulant)).to.not.equal("undefined")

  it 'filters outreach events by title',->
    expect(@page.text_fields_length()).to.equal 8
    @page.$title_input().val('F')
    simulant.fire(@page.$title_input()[0],'change')
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    expect(filter_criteria.title()).to.equal 'F'

  it 'filters outreach events by earliest date', ->
    @page.set_from_date('19/08/2014')
    expect(filter_criteria.from()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 1
    expect(@page.text_fields()).to.include "Fantasy land"

  it 'filters outreach events by latest date', ->
    @page.set_to_date('19/08/2014')
    expect(filter_criteria.to()).to.equal (new Date('08/19/2014')).getTime()
    expect(@page.text_fields_length()).to.equal 7
    expect(@page.text_fields()).to.not.include "Fantasy land"

  it 'filters outreach events by area', ->
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

  it 'filters outreach events by subarea returns matching subareas', ->
    @page.unselect_area_subarea()
    @page.open_area_dropdown()
    crc_id = (_(subareas).detect (sa)-> sa.name == "CRC").id
    @page.click_crc_subarea()
    expect(filter_criteria.subareas()).to.eql [crc_id]
    expect(@page.text_fields_length()).to.equal 1
    expect(@page.text_fields()).to.include "Fantasy land"
    @page.click_crc_subarea()
    expect(filter_criteria.areas()).to.eql []
    expect(@page.text_fields_length()).to.equal 0

  it 'filters outreach events by audience_type', ->
    expect(@page.text_fields_length()).to.equal 8
    @page.open_audience_type_dropdown()
    @page.select_audience_type('Police')
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    expect(outreach.get('filter_criteria.audience_type_id')).to.equal 1

  it 'filters outreach events by audience name', ->
    expect(@page.text_fields_length()).to.equal 8
    @page.$audience_name_input().val('Gotham')
    simulant.fire(@page.$audience_name_input()[0],'change')
    expect(@page.text_fields_length()).to.equal 2
    expect(@page.text_fields()).to.include "Fantasy land"
    expect(@page.text_fields()).to.include "May the force be with you"
    expect(outreach.get('filter_criteria.audience_name')).to.equal 'Gotham'

  it 'filters outreach events by number of participants', ->
    @page.participants('min').val(444)
    simulant.fire(@page.participants('min')[0],'change')
    @page.participants('max').val(6000)
    simulant.fire(@page.participants('max')[0],'change')
    expect(filter_criteria.pp_min()).to.equal "444"
    expect(filter_criteria.pp_max()).to.equal "6000"
    expect(@page.text_fields_length()).to.equal 1

  it 'shows error message when invalid minimum number of participants is entered', ->

  it 'shows error message when invalid maximum number of participants is entered', ->

  it 'filters outreach events by impact_rating', ->
    expect(@page.text_fields_length()).to.equal 8
    @page.open_impact_rating_dropdown()
    @page.select_impact_rating('No improved audience understanding')
    expect(@page.text_fields_length()).to.equal 1
    expect(@page.text_fields()).to.include "May the force be with you"
    expect(outreach.get('filter_criteria.impact_rating_id')).to.equal 1

  it 'shows error message when invalid minimum impact rating value is entered', ->

  it 'shows error message when invalid maximum impact rating value is entered', ->

  it 'filters outreach events by # people affected', ->
    @page.people_affected('min').val(444)
    simulant.fire(@page.people_affected('min')[0],'change')
    @page.people_affected('max').val(6000)
    simulant.fire(@page.people_affected('max')[0],'change')
    expect(filter_criteria.pa_min()).to.equal "444"
    expect(filter_criteria.pa_max()).to.equal "6000"
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
    expect(@page.$date_from().val()).to.equal '19/08/2013'
    expect(@page.$date_to().val()).to.equal '19/08/2015'
    expect(@page.people_affected('min').val()).to.equal '222'
    expect(@page.people_affected('max').val()).to.equal '999'
    expect(@page.participants('min').val()).to.equal '333'
    expect(@page.participants('max').val()).to.equal '555'
    expect(@page.impact_rating('min').val()).to.equal '999'
    expect(@page.impact_rating('max').val()).to.equal '999'
