describe 'Media page', ->
  beforeEach (done)->
    window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
    MagicLamp.load("media_appearance_page")
    $.getScript "/assets/outreach_media.js", -> done()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Media Archive"
    expect($(".media_appearance", '.magic-lamp').length).to.equal 8
    expect(typeof(simulant)).to.not.equal("undefined")

  it 'filters media appearances by title',->
    $media_appearance_controls = $('#media_appearances_controls')
    $title_input = $media_appearance_controls.find('input#title')
    text_fields = ->
      _($('.media_appearance .basic_info .title:visible','.magic-lamp')).
        map (el)-> $(el).text()
    text_fields_length = -> text_fields().length
    expect(text_fields_length()).to.equal 8
    $title_input.val('F')
    simulant.fire($title_input[0],'change')
    expect(text_fields_length()).to.equal 2
    expect(text_fields()).to.include "Fantasy land"
    expect(text_fields()).to.include "May the force be with you"
    expect(media.get('sort_criteria.title')).to.equal 'F'
    expect($('#sort_criteria #title').text()).to.equal 'F'

  it 'filters media appearances by earliest date', ->
    text_fields = ->
      _($('.media_appearance .basic_info .title:visible','.magic-lamp')).
        map (el)-> $(el).text()
    text_fields_length = -> text_fields().length
    $media_appearance_controls = $('#media_appearances_controls')
    $date_from = $media_appearance_controls.find('input#from')
    $date_to = $media_appearance_controls.find('input#to')
    $date_from.datepicker('show')
    $date_from.datepicker('setDate','08/19/2014')
    $date_from.datepicker('hide')
    expect(media.get('sort_criteria.from').getTime()).to.equal (new Date('08/19/2014')).getTime()
    expect(text_fields_length()).to.equal 1
    expect(text_fields()).to.include "Fantasy land"

  it 'filters media appearances by latest date', ->
    text_fields = ->
      _($('.media_appearance .basic_info .title:visible','.magic-lamp')).
        map (el)-> $(el).text()
    text_fields_length = -> text_fields().length
    $media_appearance_controls = $('#media_appearances_controls')
    $date_from = $media_appearance_controls.find('input#from')
    $date_to = $media_appearance_controls.find('input#to')
    $date_to.datepicker('show')
    $date_to.datepicker('setDate','08/19/2014')
    $date_to.datepicker('hide')
    expect(media.get('sort_criteria.to').getTime()).to.equal (new Date('08/19/2014')).getTime()
    expect(text_fields_length()).to.equal 7
    expect(text_fields()).to.not.include "Fantasy land"

  it 'filters media appearances by area', ->
    text_fields = ->
      _($('.media_appearance .basic_info .title:visible','.magic-lamp')).
        map (el)-> $(el).text()
    text_fields_length = -> text_fields().length
    $media_appearance_controls = $('#media_appearances_controls')
    $area = $media_appearance_controls.find('select#area')
    human_rights = $area.find('option:nth-child(1)').attr('value')
    good_governance = $area.find('option:nth-child(2)').attr('value')
    $area.val([human_rights,good_governance])
    simulant.fire($area[0],'change')
    expect(media.get('sort_criteria.areas')).to.eql [human_rights,good_governance]
    expect(text_fields_length()).to.equal 2
    expect(text_fields()).to.include "Fantasy land"
    expect(text_fields()).to.include "May the force be with you"
