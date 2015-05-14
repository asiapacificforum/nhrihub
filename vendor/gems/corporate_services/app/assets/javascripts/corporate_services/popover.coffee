$ ->
  # configure the "information" popover for the files
  # it's a twitter-bootstrap popover
  $("body").popover
    selector : '.details',
    html : true,
    title : ->
      $('#detailsTitle').html()
    content : ->
      data = $(@).closest('table.document').data()
      tmpl('detailsContent', data)
    template : $('#popover_template').html()

  # click on the 'x' close icon in the popover to close it
  $('body').on 'click', '.closepopover', ->
    $(@).closest('.template-download').find('.details').popover('hide')

  # click anywhere to close the popover
  $('html').on 'click', (e)->
    target_class = $(e.target).attr('class')
    if typeof(target_class) == "undefined" or !(target_class.match(/fa-info-circle/) or target_class.match(/glyphicon-remove/))
      $('.details').popover('hide')
