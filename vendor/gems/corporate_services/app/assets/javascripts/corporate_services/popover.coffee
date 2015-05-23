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
      template = _.template($('#detailsContent').html())
      template(data)
    template : $('#popover_template').html()
    trigger: 'hover'
