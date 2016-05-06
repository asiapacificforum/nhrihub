##############
# IN-PAGE EDIT
##############
#  example usage
#    new @InpageEdit
#      on : node
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
#    on: the root element of the editable content, a jquery node reference NOT the id, but the actual jquery object
#    focus_element : selector of element on which to apply focus when switching to edit mode
#    success : callback when save was successful
#    error : callback when save failed
#
#  requirements:
#    Needs an element with selector '.editable_container' with data attribute for save_url

#= require 'user_input_manager'

class @InpageEditElement
  constructor : (@el,@object,@attribute) ->

  switch_to_edit : (stash)->
    unless _.isUndefined(@attribute) # in which case it's a control element not an input
      if stash # object will stash and restore itself if stash is false
        @_stash() # save the value for restoral after cancel when changes have been made
    @hide(@text())
    @show(@input())

  _stash : ->
    unless _.isArray(@attribute)
      @attribute = [@attribute]
    _(@attribute).each (attr)=>
      @object.set('original_'+attr,@object.get(attr))

  switch_to_show : ->
    @load()
    unless _.isUndefined(@attribute) # in which case it's a control element not an input
      @_restore()

  load : ->
    @show(@text())
    @hide(@input())

  _restore : ->
    unless _.isArray(@attribute)
      @attribute = [@attribute]
    _(@attribute).each (attr)=>
      unless _.isUndefined(@object.get("original_"+attr))
        @object.set(attr,@object.get("original_"+attr))

  input_field : ->
    @input().find('input')

  input : ->
    $(@el).find('.edit')

  text : ->
    $(@el).find('.no_edit')

  text_width : ->
    @text().find(':first-child').width()

  show : (element)->
    element.addClass('in')

  hide : (element)->
    element.removeClass('in')

class @InpageEdit
  constructor : (options)->
    @options = options
    node = options.on
    options.object.editor = @
    if _.isFunction(options.object.validate)
      validate = true
    else
      validate = false

    #if _.isUndefined(options.object.get('url'))
      #throw new Error('Ractive object must have url defined')

    @root =
      if $(@options.on).hasClass('editable_container')
        $(@options.on)
      else
        $(@options.on).find('.editable_container')

    $(@options.on).find("[id$='_edit_start']").on 'click', (e)=>
      e.stopPropagation()
      $target = $(e.target)
      @edit_start($target)

    $(@options.on).find("[id$='_edit_cancel']").on 'click', (e)=>
      e.stopPropagation()
      $target = $(e.target)
      @edit_cancel($target)

    $(@options.on).find("[id$='_edit_save']").on 'click', (e)=>
      e.stopPropagation()
      $target = $(e.target)
      if $target.closest('.editable_container').get(0) == @root.get(0)
        if validate && !@options.object.validate()
          return
        @context = $target.closest('.editable_container')
        url = @options.object.get('url')
        if _.isFunction(@options.object.create_instance_attributes) # pull the data from the object
          data = @options.object.create_instance_attributes()
          data['_method'] = 'put'
        else
          data = @context.find(':input').serializeArray() # pull the data from the dom
          data[data.length] = {name : '_method', value : 'put'}

        if _.isFunction(@options.object.update_persist) # situations where a fileupload must be handled are delegated to the ractive object
          @options.object.update_persist(@_success,@options.error,@)
        else
          $.ajax
            url: url
            method : 'post'
            data : data
            success : @_success
            error : @options.error
            context : @

  edit_start : ($target) ->
    if $target.closest('.editable_container').get(0) == @root.get(0)
      @context = $target.closest('.editable_container')
      if _.isFunction(@options.object.stash)
        @options.object.stash()
        @edit(false)
      else
        @edit(true)
      @options.object.set('editing',true)
      @context.find(@options.focus_element).first().focus()
      if @options.start_callback
          @options.start_callback()

  edit_cancel : ($target)->
      if $target.closest('.editable_container').get(0) == @root.get(0)
        if _.isFunction(@options.object.restore)
          @options.object.restore()
        UserInput.reset()
        @options.object.set('editing',false)
        @context = $target.closest('.editable_container')
        @show()

  _success : (response, textStatus, jqXhr)->
    UserInput.reset()
    @options.success.apply(@, [response, textStatus, jqXhr])

  off : ->
    $('body').off 'click',"#{@options.on}_edit_start"
    $('body').off 'click',"#{@options.on}_edit_cancel"
    $('body').off 'click',"#{@options.on}_edit_save"

  edit : (stash)->
    _(@elements()).each (el,i) ->
      el.switch_to_edit(stash)
    UserInput.claim_user_input_request(@options.object.editor, 'show')
    @options.object.set('editing',true)

  show : ->
    @options.object.remove_errors()
    _(@elements()).each (el,i) ->
      el.switch_to_show()
    @options.object.set('editing',false)

  load : ->
    _(@elements()).each (el,i) ->
      el.load()

  # must select only elements pertaining to this instance
  # nested in-page edits must be excluded from elements
  elements : ->
    @context = $(@options.on)
    all_elements = @context.find("[data-toggle='edit']")
    elements = _(all_elements).filter (el)=>
                      $(el).closest('.editable_container').get(0) == @root.get(0)
    elements.map (el,i)=>
      object = @options.object
      attribute = $(el).data('attribute')
      new InpageEditElement(el,object,attribute)
