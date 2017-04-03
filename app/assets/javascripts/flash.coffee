$ ->
  window.flash = new Ractive
    el : "#jflash"
    template : "#flash_error_template"
    data :
      error_message :  window.flash_error
      info_message : null
      warn_message : null
      confirm_message : null
    show : ->
      $(@find('ul')).show(30)
    hide : ->
      $(@find('ul')).hide(30)
    notify : ->
      @show()

