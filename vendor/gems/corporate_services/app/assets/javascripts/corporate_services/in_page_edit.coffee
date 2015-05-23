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
        @context = $target.closest('table.document')
        @edit()
        @title_element().focus()

      $('body').on 'click', '#edit_cancel', (e)=>
        $target = $(e.target)
        @context = $target.closest('table.document')
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
  $('body').on 'click', ".edit-save", (e)->
    $el = $(e.target)
    id = $el.closest('table.document').data('id')
    url = "internal_documents/"+id
    data = $el.closest('table.document').find('input').serializeArray()
    data[data.length] = {name : '_method', value : 'put'}
    $.post(url, data, (response, text, jqXhr)->
      # TODO eventually need to return an object and not an array, the array is 'legacy'
      # but template needs to be modified to deal with single objects
      id = response.files[0].id
      source = $("table.document[data-id='"+id+"']").closest('.template-download')
      new_template = _.template($('#template-download').html())
      source.replaceWith(new_template(response))
      ).fail ->
        console.log "Changes were not saved, for some reason"
