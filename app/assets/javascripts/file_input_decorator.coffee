import Ractive from 'ractive'
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
    input = $(node)
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
