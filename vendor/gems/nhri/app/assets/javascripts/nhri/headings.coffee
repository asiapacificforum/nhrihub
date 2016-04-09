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

  HumanRightsAttribute = Ractive.extend
    template : "#attribute_template"
    validate : ->
      @set('description', @get('description').trim())
      @set('description_error', _.isEmpty(@get('description')))
      !@get('description_error')
    deselect_attribute : ->
      @parent.remove(@_guid)

  EditHumanRightsAttribute = Ractive.extend
    template : "#edit_attribute_template"
    computed :
      persisted : ->
        !_.isNull @get('id')
      url : ->
        Routes.nhri_heading_human_rights_attribute_path(current_locale, @get('heading_id'), @get('id'))
    validate : ->
      @set('description', @get('description').trim())
      @set('description_error', _.isEmpty(@get('description')))
      !@get('description_error')
    terminate_attribute : ->
      @parent.remove_edit_attribute(@_guid)
    save_attribute : ->
      if @validate()
        url = Routes.nhri_heading_human_rights_attributes_path(current_locale, @get('heading_id'))
        data = {human_rights_attribute : {description : @get('description')}}
        $.ajax
          method : 'post'
          url : url
          data : data
          success : @create_attribute_callback
          context : @
    create_attribute_callback : (response, status, jqxhr)->
      @set(response)
    validate : ->
      @set('description', @get('description').trim())
      @set('description_error', _.isEmpty(@get('description')))
      !@get('description_error')
    remove_errors : ->
      @set('description_error', false)
    delete_attribute : ->
      data = {_method : 'delete'}
      $.ajax
        method : 'post'
        url : @get('url')
        data : data
        success : @delete_callback
        context : @
    delete_callback : ->
      @parent.remove_edit_attribute(@_guid)
    create_instance_attributes : ->
      {human_rights_attribute : {description : @get('description')}}
    remove_description_error : ->
      @set('description_error', false)

  Heading = Ractive.extend
    template : "#heading_template"
    computed :
      persisted : ->
        !_.isNull @get('id')
      url : ->
        Routes.nhri_heading_path(current_locale,@get('id'))
      human_rights_attributes_attributes : ->
        if _.isEmpty(@get('human_rights_attributes'))
          [{description: ""}] # hack to workaround jQuery not sending empty arrays
        else
          _(@get('human_rights_attributes')).map (o)-> _(o).pick('id','description')
    components :
      attribute : HumanRightsAttribute
      editHumanRightsAttribute : EditHumanRightsAttribute
    on_init : ->
      @remove_errors()
      @set('expanded',false)
    save_heading : ->
      data = {heading : {title : @get('title'), human_rights_attributes_attributes : @get('human_rights_attributes_attributes')}}
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
      {heading: {title : @get('title'), human_rights_attributes_attributes : @get('human_rights_attributes_attributes')}}
    add_attribute : ->
      # here we don't claim_user_input_request b/c
      # we will allow adding heading and adding attribute simultaneously
      @_add_attribute_in('attribute')
    add_edit_attribute : ->
      UserInput.claim_user_input_request(@,'remove_edit_attribute')
      @_add_attribute_in('editHumanRightsAttribute')
    _add_attribute_in : (collection)->
      attributes = @findAllComponents(collection)
      first_attribute = attributes.length == 0
      valid_previous_attribute = first_attribute || !(_.isNull(attributes[0].get('id')) && !attributes[0].validate())
      if valid_previous_attribute
        @unshift('human_rights_attributes',{heading_id : @get('id'), id : null, description : '', description_error : false})
    remove : (guid)->
      @_remove_attribute_from('attribute',guid)
    remove_edit_attribute : (guid)->
      @_remove_attribute_from('editHumanRightsAttribute',guid)
    _remove_attribute_from : (collection,guid)->
      guids = _(@findAllComponents(collection)).pluck('_guid')
      index = _(guids).indexOf(guid)
      @splice('human_rights_attributes',index,1)
    toggle_attributes : ->
      UserInput.terminate_user_input_request()
      UserInput.reset()
      @set('expanded',!@get('expanded'))
      $("#edit_attributes#{@get('id')}").collapse('toggle')

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
      @unshift('headings',{id: null, title : "", title_error: false, human_rights_attributes: []})
    components :
      headings : Headings
    cancel : ->
      @shift('headings')
