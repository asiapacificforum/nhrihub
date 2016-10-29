confirm_delete_modal = null
$ ->
  confirm_delete_modal = new Ractive
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
      @get('callback').apply(@get('deletable'),[response, statusText, jqxhr])
    error_callback : ->
      console.log "error callback"
    delete_item : ->
      -#ev = $.Event(event)
      -#ev.stopPropagation()
      if _.isEmpty(@get('local_data'))
        data = [{name:'_method', value: 'delete'}]
      else
        # this should be generalized
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
    confirm_delete_modal.set
      deletable : @
      url : @get('url')
      message : @get('delete_confirmation_message')
      callback : @delete_callback
      local_data : local_data
    confirm_delete_modal.show()
    return
