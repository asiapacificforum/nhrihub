$ ->
  $('#from').datepicker
    defaultDate: '+1w'
    changeMonth: true
    numberOfMonths: 3
    onClose: (selectedDate) ->
      media.set('sort_criteria.from',new Date(selectedDate))
      $('#to').datepicker 'option', 'minDate', selectedDate
  $('#to').datepicker
    defaultDate: '+1w'
    changeMonth: true
    numberOfMonths: 3
    onClose: (selectedDate) ->
      media.set('sort_criteria.to',new Date(selectedDate))
      $('#from').datepicker 'option', 'maxDate', selectedDate
