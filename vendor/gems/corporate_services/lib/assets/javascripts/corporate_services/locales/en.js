if(typeof locale == 'undefined'){ window.locale = {} };

$.extend( window.locale,
    { "en":{
        "corporate_services": {
          "internal_documents": {
            "fileupload": {
              "errors": {
                  "maxFileSize": "File is too large",
                  "minFileSize": "File is too small",
                  "acceptFileTypes": "File type not allowed",
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
          } //internal_documents
        } //corporate_services
      } //en
    } //top
  );
