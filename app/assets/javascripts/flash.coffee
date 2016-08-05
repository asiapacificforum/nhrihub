$ ->
  window.flash = new Ractive
    el : ".message_block"
    template : "#flash_error_template"
    data :
      message :  window.files_list_error
    show : ->
      $(@find('ul.error')).show()
    hide : ->
      $(@find('ul.error')).hide()
    notify : ->
      @show()

