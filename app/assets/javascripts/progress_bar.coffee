@ProgressBar = Ractive.extend
  template : '#progress_bar_template'
  progressbar_start : ->
    # this is called for each file being uploaded
    $('.fileupload-progress.fade').addClass('in')
  progress_evaluate : (evt)->
    if evt.lengthComputable
      percentComplete = evt.loaded / evt.total
      percentComplete = parseInt(percentComplete * 100)
      $('.progress-bar').css('width',"#{percentComplete}%")
  start : ->
    xhr = new XMLHttpRequest()
    xhr.upload.addEventListener 'loadstart', @progressbar_start , false
    xhr.upload.addEventListener 'progress', @progress_evaluate , false
    xhr
