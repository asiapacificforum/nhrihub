$ ->
  window.flash = new Ractive
    el : ".message_block"
    template : "#flash_error_template"
    data :
      message :  window.flash_error
    show : ->
      $(@find('ul.error')).show(30)
    hide : ->
      $(@find('ul.error')).hide(30)
    notify : ->
      @show()

