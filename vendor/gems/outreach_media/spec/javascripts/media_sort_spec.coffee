describe 'Media page', ->
  beforeEach (done)->
    window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
    MagicLamp.load("media_appearance_page")
    $.getScript "/assets/outreach_media/media/media_appearances.js", -> done()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Media Archive"
    expect($(".media_appearance", '.magic-lamp').length).to.equal 8

  it 'filters media appearances by title',->
    $media_appearance_controls = $('#media_appearances_controls')
    $title_input = $media_appearance_controls.find('input#title')
    text_fields = _($('.media_appearance .basic_info .title','.magic-lamp')).map (el)-> $(el).text()
    expect(text_fields.length).to.equal 8
    $title_input.val('F')
    expect(text_fields.length).to.equal 1
    #expect(text_fields).to.include "Fantasy land"
    #check the sort criteria is set with 'F'
    #check the displayed titles are matched to 'F'
    #check the displayed filter criteria shows title matches 'F'
    #expect(titles).to.include('Funny thing happened')
    #and other fuzzy matches
