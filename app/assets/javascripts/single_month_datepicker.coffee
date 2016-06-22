Datepicker = (node)->
  $(node).datepicker
    maxDate: null
    defaultDate: new Date()
    changeMonth: true
    changeYear: true
    numberOfMonths: 1
    dateFormat: "yy, M d"
    onClose: (selectedDate) ->
      unless selectedDate == ""
        object = Ractive.getNodeInfo(node).ractive
        object.set('formatted_date',selectedDate)
  teardown : ->
    $(node).datepicker('destroy')

Ractive.decorators.datepicker = Datepicker
