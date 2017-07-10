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
      _(['error','info','warn','confirm']).each (type)=>
        unless _.isNull(@get("#{type}_message")) || _.isUndefined(@get("#{type}_message"))
          $(@find("ul.#{type}")).show(30)
    hide : ->
      $(@findAll('ul')).hide(30)
    notify : ->
      @show()
    error : (message) ->
      @set('error_message', message)
      @show()
    info : (message) ->
      @set('info_message', message)
      @show()
    warn : (message) ->
      @set('warn_message', message)
      @show()
    confirm : (message) ->
      @set('confirm_message', message)
      @show()

