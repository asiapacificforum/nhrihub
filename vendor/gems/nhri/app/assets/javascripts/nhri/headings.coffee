$ ->
  Ractive.DEBUG = false

  EditInPlace = (node,id)->
    ractive = @
    ractive.edit = new InpageEdit
      object : @
      on : node
      focus_element : 'input#heading_title'
      success : (response, statusText, jqxhr)->
         ractive = @options.object
         @show() # before updating b/c we'll lose the handle
         ractive.set(response)
      error : ->
        console.log "Changes were not saved, for some reason"
    teardown : ->
      ractive.edit.off()
    update : ->
      # update method seems to be required else bad things happen, even when it doesn't do anything!

  Ractive.decorators.inpage_edit = EditInPlace

  Offence = Ractive.extend
    template : "#offence_template"
    validate : ->
      @set('description', @get('description').trim())
      @set('description_error', _.isEmpty(@get('description')))
      !@get('description_error')
    deselect_offence : ->
      @parent.remove(@_guid)

  EditOffence = Ractive.extend
    template : "#edit_offence_template"
    computed :
      persisted : ->
        !_.isNull @get('id')
      url : ->
        Routes.nhri_heading_offence_path(current_locale, @get('heading_id'), @get('id'))
    validate : ->
      @set('description', @get('description').trim())
      @set('description_error', _.isEmpty(@get('description')))
      !@get('description_error')
    terminate_offence : ->
      @parent.remove_edit_offence(@_guid)
    save_offence : ->
      if @validate()
        url = Routes.nhri_heading_offences_path(current_locale, @get('heading_id'))
        data = {offence : {description : @get('description')}}
        $.ajax
          method : 'post'
          url : url
          data : data
          success : @create_offence_callback
          context : @
    create_offence_callback : (response, status, jqxhr)->
      @set(response)
    validate : ->
      @set('description', @get('description').trim())
      @set('description_error', _.isEmpty(@get('description')))
      !@get('description_error')
    remove_errors : ->
      @set('description_error', false)
    delete_offence : ->
      data = {_method : 'delete'}
      $.ajax
        method : 'post'
        url : @get('url')
        data : data
        success : @delete_callback
        context : @
    delete_callback : ->
      @parent.remove_edit_offence(@_guid)
    create_instance_attributes : ->
      {offence : {description : @get('description')}}
    remove_description_error : ->
      @set('description_error', false)

  Heading = Ractive.extend
    template : "#heading_template"
    computed :
      persisted : ->
        !_.isNull @get('id')
      url : ->
        Routes.nhri_heading_path(current_locale,@get('id'))
      offences_attributes : ->
        if _.isEmpty(@get('offences'))
          [{description: ""}] # hack to workaround jQuery not sending empty arrays
        else
          _(@get('offences')).map (o)-> _(o).pick('id','description')
    components :
      offence : Offence
      editOffence : EditOffence
    on_init : ->
      @remove_errors()
      @set('expanded',false)
    save_heading : ->
      data = {heading : {title : @get('title'), offences_attributes : @get('offences_attributes')}}
      url = Routes.nhri_headings_path(current_locale)
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
      UserInput.reset()
      @parent.remove(@)
    validate : ->
      @set('title_error',_.isEmpty(@get('title').trim()))
      !@get('title_error')
    delete_this : ->
      data = {'_method' : 'delete'}
      # TODO if confirm
      $.ajax
        method : 'post'
        url : @get('url')
        data : data
        success : @delete_callback
        dataType : 'json'
        context : @
    delete_callback : (data,textStatus,jqxhr)->
      @parent.remove(@)
    remove_errors : ->
      @set('title_error',false)
    create_instance_attributes : -> # required for inpage_edit decorator
      {heading: {title : @get('title'), offences_attributes : @get('offences_attributes')}}
    add_offence : ->
      # here we don't claim_user_input_request b/c
      # we will allow adding heading and adding offence simultaneously
      @_add_offence_in('offence')
    add_edit_offence : ->
      UserInput.claim_user_input_request(@,'remove_edit_offence')
      @_add_offence_in('editOffence')
    _add_offence_in : (collection)->
      offences = @findAllComponents(collection)
      first_offence = offences.length == 0
      valid_previous_offence = first_offence || !(_.isNull(offences[0].get('id')) && !offences[0].validate())
      if valid_previous_offence
        @unshift('offences',{heading_id : @get('id'), id : null, description : '', description_error : false})
    remove : (guid)->
      @_remove_offence_from('offence',guid)
    remove_edit_offence : (guid)->
      @_remove_offence_from('editOffence',guid)
    _remove_offence_from : (collection,guid)->
      guids = _(@findAllComponents(collection)).pluck('_guid')
      index = _(guids).indexOf(guid)
      @splice('offences',index,1)
    toggle_offences : ->
      UserInput.terminate_user_input_request()
      UserInput.reset()
      @set('expanded',!@get('expanded'))
      $("#edit_offences#{@get('id')}").collapse('toggle')

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
      headings : headings_data
    new_heading : ->
      UserInput.claim_user_input_request(@,'cancel')
      @unshift('headings',{id: null, title : "", title_error: false, offences: []})
    components :
      headings : Headings
    cancel : ->
      @shift('headings')
