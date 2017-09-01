@Remindable =
  show_reminders_panel : ->
    reminders.set # copy this object's reminders into the global reminders object
      reminders: @get('reminders')
      create_reminder_url : @get('create_reminder_url')
      parent : @
    $('#reminders_modal').modal('show')
