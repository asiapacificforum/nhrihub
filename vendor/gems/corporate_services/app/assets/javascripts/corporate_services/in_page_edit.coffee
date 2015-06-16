##############
# IN-PAGE EDIT
##############
#  example usage
#    new @InpageEdit
#      focus_element : 'input.title'
#      success : (response, textStatus, jqXhr)->
#        id = response.id
#        source = $("table.document[data-id='"+id+"']").closest('.template-download')
#        new_template = _.template($('#template-download').html())
#        source.replaceWith(new_template({file:response}))
#      error : ->
#        console.log "Changes were not saved, for some reason"
#
#  options:
#    focus_element : selector of element on which to apply focus when switching to edit mode
#    success : callback when save was successful
#    error : callback when save failed
#
#  requirements:
#    Needs an element with selector '.editable_container' with data attribute for save_url
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
    constructor : (options)->
      @options = options

      $('body').on 'click', '#edit_start', (e)=>
        $target = $(e.target)
        @context = $target.closest('.editable_container')
        @edit()
        @context.find(@options.focus_element).first().focus()

      $('body').on 'click', '#edit_cancel', (e)=>
        $target = $(e.target)
        @context = $target.closest('.editable_container')
        @show()

      $('body').on 'click', ".edit-save", (e)=>
       $target = $(e.target)
       url = @data().save_url
       data = @context.find(':input').serializeArray()
       data[data.length] = {name : '_method', value : 'put'}
       $.ajax
         url: url
         method : 'post'
         data : data
         success : @options.success
         error : @options.error

    edit : ->
      @elements().each (i,el) ->
        el.switch_to_edit()

    show : ->
      @elements().each (i,el) ->
        el.switch_to_show()

    elements : ->
      @context.find("[data-toggle='edit']").map (i,el)->
        new document.InpageEditElement(el)

    data : ->
      @context.data()
