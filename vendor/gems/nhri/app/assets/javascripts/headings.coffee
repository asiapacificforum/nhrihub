$ ->
  Ractive.DEBUG = false

  EditInPlace = (node,id)->
    edit = new InpageEdit
      object : @
      on : node
      focus_element : 'input.title'
      success : (response, statusText, jqxhr)->
         ractive = @options.object
         @show() # before updating b/c we'll lose the handle
         ractive.set(response)
      error : ->
        console.log "Changes were not saved, for some reason"
    teardown : ->
      edit.off()

  Ractive.decorators.inpage_edit = EditInPlace

  Heading = Ractive.extend
    template : "#heading_template"
    computed :
      persisted : ->
        !_.isNull @get('id')
    on_init : ->
      @remove_errors()
    save_heading : ->
      data = {heading : {title : @get('title')}}
      url = create_heading_url
      if @validate()
        $.ajax
          method : 'post'
          url : url
          data : data
          success : @create_callback
          dataType : 'json'
          context : @
    create_callback : (response, status, jqxhr)->
      @set(response)
    cancel_new_heading : ->
      @parent.remove(@)
    validate : ->
      @set('title_error',_.isEmpty(@get('title').trim()))
      !@get('title_error')
    delete_this : ->
    delete_this : (event) ->
      data = {'_method' : 'delete'}
      url = @get('url')
      # TODO if confirm
      $.ajax
        method : 'post'
        url : url
        data : data
        success : @delete_callback
        dataType : 'json'
        context : @
    delete_callback : (data,textStatus,jqxhr)->
      @parent.remove(@)
    remove_errors : ->
      @set('title_error',false)
    create_instance_attributes : -> # required for inpage_edit decorator
      {heading: {title : @get('title')}}

  Headings = Ractive.extend
    template : "{{#headings}}<heading id='{{id}}' title='{{title}}' />{{/headings}}"
    components :
      heading : Heading
    remove : (heading)->
      index = _(@findAllComponents('heading')).indexOf(heading)
      @splice('headings',index,1)

  window.headings = new Ractive
    el : '#headings_container'
    template : "<headings headings='{{headings}}' />"
    data :
      headings : headings
    new_heading : ->
      UserInput.claim_user_input_request(@,'cancel')
      @unshift('headings',{id: null, title : "", title_error: false})
    components :
      headings : Headings
    cancel : ->
      @shift('headings')
