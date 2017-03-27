re = new RegExp('phantomjs','gi')
log = (str)->
  unless re.test navigator.userAgent
    console.log str

describe 'Headings page', ->
  before (done)->
    window.headings_data = MagicLamp.loadJSON('headings_data')
    MagicLamp.load("headings_page") # that's the _index partial being loaded
    $.getScript("/assets/nhri/headings.js").
      done( -> 
        log "(Headings page) javascript was loaded"
        done()).
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

  beforeEach ->
    $('#banner').css('display','none')
    #set_defaults()

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Human Rights Indicators: Headings"
    expect(typeof(simulant)).to.not.equal("undefined")

  it 'does not initially make edit or add panels visible', ->
    expect($('#new_heading:visible').length).to.equal 0
    expect($('.collapse').length).to.equal 1
    expect($('.collapse.in').length).to.equal 0
    expect($('.attribute .edit:visible').length).to.equal 0

  context 'when showing attributes', ->
    beforeEach ->
      $('.show_attributes').first().trigger('click')

    it 'it disallows multiple simultaneous attribute add panels', ->
      expect($('.attribute .description .no_edit:visible').length).to.equal 3
      # first add
      $('#add_attribute').trigger('click')
      # check expected conditions for first add
      expect($('#new_attribute').length).to.equal 1
      expect($('#description_error:visible').length).to.equal 0
      expect($('.attribute .description .no_edit:visible').length).to.equal 3 # doesn't change existing attributes
      # second add
      $('#add_attribute').click()
      # conditions should be the same as after the first add
      expect($('#new_attribute').length).to.equal 1
      expect($('#description_error:visible').length).to.equal 0
      expect($('.attribute .description .no_edit:visible').length).to.equal 3

    it 'can terminate adding attribute leaving existing attributes unchanged', ->
      $('#add_attribute').click()
      $('#terminate_attribute').click()
      expect($('#new_attribute').length).to.equal 0
      expect($('.attribute .description .no_edit:visible').length).to.equal 3
      # b/c there was a bug!
      $('#add_attribute').click()
      expect($('.attribute .description .no_edit:visible').length).to.equal 3

    it "terminates editing when the dropdown is closed", ->
      $("#attributes .attribute i[id$='edit_start']").first().click()
      expect($("input#attribute_description:visible").length).to.equal 1
      $('.show_attributes').first().trigger('click')
      $('.show_attributes').first().trigger('click')
      expect($("input#attribute_description:visible").length).to.equal 0

  context 'when adding a new heading', ->
    it 'it permits multiple simultaneous attribute add panels', ->
      $('#add_heading').click()
      # add first attribute
      $('#add_attribute').click()
      expect($('.new_attribute').length).to.equal 1
      # add second attribute without filling in the first description
      $('#add_attribute').click()
      expect($('.new_attribute').length).to.equal 1
      # fill in the first description
      $('.new_attribute .attribute_description').val('foo')
      simulant.fire($('.new_attribute .attribute_description')[0], 'change')
      # add second attribute 
      $('#add_attribute').click()
      expect($('.new_attribute').length).to.equal 2
