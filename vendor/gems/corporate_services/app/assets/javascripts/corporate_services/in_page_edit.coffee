##############
# IN-PAGE EDIT
##############
#  example usage
#    new @InpageEdit
#      on : 'div#some_id'
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
#    on: the root element of the editable content
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
      console.log("init inpage edit with #{options.on}")

      #$('body').on 'click', "#{@options.on} #edit_start", (e)=>
      $("#{@options.on}_edit_start").on 'click', (e)=>
        e.stopPropagation()
        console.log "starting"
        $target = $(e.target)
        @context = $target.closest('.editable_container')
        @edit()
        @context.find(@options.focus_element).first().focus()

      #$('body').on 'click', "#{@options.on} #edit_cancel", (e)=>
      $("#{@options.on}_edit_cancel").on 'click', (e)=>
        e.stopPropagation()
        console.log "cancel #{JSON.stringify(e.target)}"
        $target = $(e.target)
        @context = $target.closest('.editable_container')
        @show()

      $("#{@options.on}_edit_save").on 'click', (e)=>
       e.stopPropagation()
       $target = $(e.target)
       url = @data().update_url
       data = @context.find(':input').serializeArray()
       data[data.length] = {name : '_method', value : 'put'}
       $.ajax
         url: url
         method : 'post'
         data : data
         success : @options.success
         error : @options.error
         context : @

    edit : ->
      _(@elements()).each (el,i) ->
        el.switch_to_edit()

    show : ->
      _(@elements()).each (el,i) ->
        el.switch_to_show()

    # must select only elements pertaining to this instance
    # nested in-page edits must be excluded from elements
    elements : ->
      all_elements = @context.find("[data-toggle='edit']")
      if $(@options.on).hasClass('editable_container')
        root = $(@options.on)
      else
        root = $(@options.on).find('.editable_container')
      elements = _(all_elements).filter (el)->
                        $(el).closest('.editable_container').get(0) == root.get(0)
      elements.map (el,i)->
        new document.InpageEditElement(el)

    data : ->
      @context.data()
