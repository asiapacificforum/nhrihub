$ ->
  window.confirm_delete_modal = new Ractive
    el : '#confirm_delete_modal_container'
    template : '#confirm_delete_modal_template'
    data :
      deletable : null
      url : null
      message : null
      callback : null
      local_data : null
    show : ->
      $(@el).find('.modal#confirm-delete').modal('show')
      $(@el).find('.modal#confirm-delete').find('.modal-body').html(@get('message'))
    hide : ->
      $(@el).find('.modal#confirm-delete').modal('hide')
    success_callback : (response, statusText, jqxhr)->
      @hide()
      @get('unbound.callback').apply(@get('deletable'),[response, statusText, jqxhr])
      return
    error_callback : ->
      console.log "app/assets/javascripts/confirm_delete_modal error callback, shouldn't see this!"
    delete_item : ->
      if _.isEmpty(@get('local_data'))
        data = [{name:'_method', value: 'delete'}]
      else
        #TODO this should be generalized
        data = [{name:'_method', value: 'delete'},{name:'monitor[type]', value:@get('local_data').type}]
      $.ajax
        url : @get('url')
        data : data
        method : 'post'
        dataType : 'json'
        context : @
        success : @success_callback
        error : @error_callback

@ConfirmDeleteModal =
  show_confirm_delete_modal : (local_data={})->
    throw "url not defined" if _.isUndefined(@get('url'))
    throw "delete confirmation message not defined" if _.isUndefined(@get('delete_confirmation_message'))
    confirm_delete_modal.set
      deletable : @
      url : @get('url')
      message : @get('delete_confirmation_message')
      'unbound.callback' : @delete_callback # seems strange? see https://github.com/ractivejs/ractivejs.github.io/issues/92
      local_data : local_data
    confirm_delete_modal.show()
    return
