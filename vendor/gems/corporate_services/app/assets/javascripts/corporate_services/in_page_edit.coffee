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
class @InpageEditElement
  constructor : (@el,@object,@attribute) ->

  switch_to_edit : ->
    unless _.isUndefined(@attribute) # in which case it's a control element not an input
      @_stash()
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
    if _.isFunction(options.object.validate)
      validate = true
    else
      validate = false

    @root =
      if $(@options.on).hasClass('editable_container')
        $(@options.on)
      else
        $(@options.on).find('.editable_container')

    $(@options.on).find("[id$='_edit_start']").on 'click', (e)=>
      e.stopPropagation()
      $target = $(e.target)
      if $target.closest('.editable_container').get(0) == @root.get(0)
        @context = $target.closest('.editable_container')
        @edit(@options.object)
        @context.find(@options.focus_element).first().focus()

    $(@options.on).find("[id$='_edit_cancel']").on 'click', (e)=>
      e.stopPropagation()
      $target = $(e.target)
      if $target.closest('.editable_container').get(0) == @root.get(0)
        UserInput.reset()
        @context = $target.closest('.editable_container')
        @show()

    $(@options.on).find("[id$='_edit_save']").on 'click', (e)=>
      e.stopPropagation()
      $target = $(e.target)
      if $target.closest('.editable_container').get(0) == @root.get(0)
        if validate && !@options.object.validate()
          return
        @context = $target.closest('.editable_container')
        url = @options.object.get('url')
        data = @context.find(':input').serializeArray()
        data[data.length] = {name : '_method', value : 'put'}
        $.ajax
          url: url
          method : 'post'
          data : data
          success : @_success
          error : @options.error
          context : @

  _success : (response, textStatus, jqXhr)->
    UserInput.reset()
    @options.success.apply(@, [response, textStatus, jqXhr])

  off : ->
    $('body').off 'click',"#{@options.on}_edit_start"
    $('body').off 'click',"#{@options.on}_edit_cancel"
    $('body').off 'click',"#{@options.on}_edit_save"

  edit : ->
    _(@elements()).each (el,i) ->
      el.switch_to_edit()
    UserInput.claim_user_input_request(@options.object.edit, 'show')

  show : ->
    @options.object.remove_errors()
    _(@elements()).each (el,i) ->
      el.switch_to_show()

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
