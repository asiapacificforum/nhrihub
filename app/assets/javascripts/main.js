$(function () {
  'use strict';

  // Initialize the jQuery File Upload widget:
  $('#fileupload').fileupload({
      url: 'internal_documents',
      paramName: 'document[file]'
  });


  // Load existing files:
  //$('#fileupload').addClass('fileupload-processing');
  //$.ajax({
      //url: $('#fileupload').fileupload('option', 'url'),
      //dataType: 'json',
      //context: $('#fileupload')[0]
  //}).always(function () {
      //$(this).removeClass('fileupload-processing');
  //}).done(function (result) {
      //$(this).fileupload('option', 'done')
          //.call(this, $.Event('done'), {result: result});
  //});


  // don't submit if there's a required field that hasn't been filled-in
  $('#fileupload').bind('fileuploadsubmit', function (e, data) {
    var inputs = data.context.find(':input');
    if (inputs.filter(function () {
            return !this.value && $(this).prop('required');
        }).first().focus().length) {
        data.context.find('button').prop('disabled', false);
        return false;
    }
    data.formData = inputs.serializeArray();
  });

});

// changes to trigger asset precompile
