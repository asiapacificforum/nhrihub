##############
# IN-PAGE EDIT
##############
$ ->
  class @InpageEditElement
    constructor : (@el) ->

    switch_to_edit : ->
      @set_field_width()
      @show(@input())
      @hide(@text())

    switch_to_show : ->
      @show(@text())
      @hide(@input())

    set_field_width : ->
      @input().find('input').css('width',@text_width()+10)

    input : ->
      $(@el).find('.edit')

    text : ->
      $(@el).find('.no_edit')

    text_width : ->
      @text().find(':first-child').width()

    show : (element)->
      element.css("opacity",1).css("z-index",10)

    hide : (element)->
      element.css("opacity",0).css("z-index",9)

  class @InpageEdit
    constructor : ->
      $('body').on 'click', '#edit_start', (e)=>
        $target = $(e.target)
        @context = $target.closest('.template-download')
        @edit()
        @title_element().focus()

      $('body').on 'click', '#edit_cancel', (e)=>
        $target = $(e.target)
        @context = $target.closest('.template-download')
        @show()

    edit : ->
      @elements().each (i,el) ->
        el.switch_to_edit()

    show : ->
      @elements().each (i,el) ->
        el.switch_to_show()

    elements : ->
      @context.find("[data-toggle='edit']").map (i,el)->
        new document.InpageEditElement(el)

    title_element : ->
      @context.find('input.title')

  window.inpage_edit = new @InpageEdit

  # after edit, send changes to the server via ajax
  $('body').on 'click', ".glyphicon-ok", (e)->
    $el = $(e.target)
    data = {'_method':'put'}
    id = $el.closest('table.document').data('id')
    url = "internal_documents/id".replace(/id/,id)
    data['internal_document'] = {}
    data['internal_document']['title'] = $el.closest('.template-download').find('.edit .title').val()
    data['internal_document']['revision'] = $el.closest('.template-download').find('.edit .revision').val()
    $.post(url, data, (response, text, jqXhr)->
      # TODO eventually need to return an object and not an array, the array is 'legacy'
      # but tmpl needs to be modified to deal with single objects
      #console.log text
      #console.log JSON.stringify(response)
      id = response.files[0].id
      source = $("table.document[data-id='"+id+"']").closest('.template-download')
      new_template = tmpl($('#template-download').html(), response)
      source.replaceWith(new_template)
      ).fail ->
        #console.log "Changes were not saved, for some reason"
        #alerts seem to cause test failures
        alert 'Changes were not saved, for some reason.'
