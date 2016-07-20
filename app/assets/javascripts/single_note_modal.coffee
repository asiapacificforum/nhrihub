note = new Ractive
  el : '#single_note'
  template : '#single_note_template'

@Note =
  show_note : ->
    note.set
      note : @get('note')
    $('#single_note_modal').modal('show')
