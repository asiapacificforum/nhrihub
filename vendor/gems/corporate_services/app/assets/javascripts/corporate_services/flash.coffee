$ ->
  window.flash = new Ractive
    el : ".message_block"
    template : "#flash_error_template"
    data :
      message :  files_list_error
    computed :
      empty_fileslist : ->
        $('#uploads .template-upload').length == 0
    show : ->
      $(@find('ul.error')).show()
    hide : ->
      $(@find('ul.error')).hide()
    notify : ->
      if @get('empty_fileslist')
        @show()
      else
        @hide()

