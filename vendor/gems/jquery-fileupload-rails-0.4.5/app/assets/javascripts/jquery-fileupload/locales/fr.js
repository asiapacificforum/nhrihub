if(typeof locale == 'undefined'){ window.locale = {} };

$.extend( window.locale,
    { "fr":{
        "jquery": {
          "fileupload": {
            "errors": {
                "maxFileSize": "File is too large",
                "minFileSize": "File is too small",
                "acceptFileTypes": "File type not allowed. Permitted file types: {types}",
                "maxNumberOfFiles": "Maximum number of files exceeded",
                "uploadedBytes": "Uploaded bytes exceed file size",
                "emptyResult": "Empty file upload result",
                "unknownError": "Unknown error"
            },
            "error": "Error",
            "start": "Start",
            "cancel": "Cancel",
            "destroy": "Delete"
          } //fileupload
        } //jquery
      } //en
    } //top
  );

