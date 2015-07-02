$ ->
  # configure the "information" popover for the files
  # it's a twitter-bootstrap popover
  $("body").popover
    selector : '.details',
    html : true,
    title : ->
      $('#detailsTitle').html()
    # note using underscore template herr
    # TODO migrate to ractive!
    content : ->
      data = Ractive.getNodeInfo(@).ractive.get()
      template = _.template($('#detailsContent').html())
      template(data)
    template : $('#popover_template').html()
    trigger: 'hover'
