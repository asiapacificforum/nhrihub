re = new RegExp('phantomjs','gi')
log = (str)->
  unless re.test navigator.userAgent
    console.log str

describe 'Internal document', ->
  before (done)->
    window.files = MagicLamp.loadJSON('internal_document_data')
    window.maximum_filesize = MagicLamp.loadJSON('internal_document_maximum_filesize')
    #window.permitted_filetypes = MagicLamp.loadJSON('internal_document_permitted_filetypes')
    window.permitted_filetypes = ['pdf']
    window.files_list_error = MagicLamp.loadRaw('no_files_error_message')
    window.required_files_titles = MagicLamp.loadJSON('required_files_titles')
    window.accreditation_required_document = MagicLamp.loadRaw('accreditation_required_document')
    MagicLamp.load("internal_document_page") # that's the _index partial being loaded
    $.getScript("/assets/corporate_services.js").
      then($.getScript("/assets/corporate_services/internal_documents.js").
      done( ->
        log "(Internal documents page) javascript was loaded"
        done()).
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception))

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Internal Documents"
    expect($(".internal_document", '.magic-lamp').length).to.equal 4
    expect(typeof(simulant)).to.not.equal("undefined")

  it "fixes document titles for icc accreditation docs", ->
    docs = _(internal_document_uploader.findAllComponents('doc')).select (doc)->doc.get('title').match(/Statement of Compliance/) 
    doc_group_id = docs[0].get('document_group_id')
    internal_document_uploader.push('upload_files',{})
    upload_file = internal_document_uploader.findAllComponents('uploadfile')[0]
    upload_file.set('document_group_id',doc_group_id)
    expect(upload_file.get('title')).to.equal("Statement of Compliance")
