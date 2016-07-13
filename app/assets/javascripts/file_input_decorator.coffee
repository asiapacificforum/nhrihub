@FileInput = (node)->
  $(node).on 'change', (event)->
    add_file(event,@)
  $(node).closest('.fileupload').find('.fileinput-button').on 'click', (event)->
    $(@).parent().find('input:file').trigger('click')
  add_file = (event,el)->
    file = el.files[0]
    ractive = Ractive.getNodeInfo($(el).closest('.fileupload')[0]).ractive
    ractive.add_file(file)
    _reset_input()
  _reset_input = ->
    # this technique comes from jQuery.fileupload does'nt work well with ractive
    input = $(node)
    #inputClone = input.clone(true)
    # make a form and reset it. A hack to reset the fileinput element
    #$('<form></form>').append(inputClone)[0].reset()
    # Detaching allows to insert the fileInput on another form
    # without losing the file input value:
    # detaches the original fileInput and leaves the clone in the DOM
    #input.after(inputClone).detach()
    # Avoid memory leaks with the detached file input:
    #$.cleanData input.unbind('remove')
    input.wrap('<form></form>').closest('form').get(0).reset()
    input.unwrap()
  return {
    teardown : ->
      $(node).off 'change'
      $(node).closest('.fileupload').find('.fileinput-button').off 'click'
    update : ->
      #noop
  }

Ractive.decorators.ractive_fileupload = @FileInput
