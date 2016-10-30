log = (str)->
  re = new RegExp('phantomjs','gi')
  unless re.test navigator.userAgent
    console.log str

describe 'Internal document', ->
  before (done)->
    window.files = MagicLamp.loadJSON('internal_document_data').files
    window.required_files_titles = MagicLamp.loadJSON('internal_document_data').required_files_titles
    window.maximum_filesize = MagicLamp.loadJSON('internal_document_maximum_filesize')
    window.permitted_filetypes = ['pdf']
    window.files_list_error = MagicLamp.loadRaw('no_files_error_message')
    window.accreditation_required_document = MagicLamp.loadRaw('accreditation_required_document')
    MagicLamp.load("internal_document_page") # that's the _index partial being loaded
    $.getScript("/assets/internal_documents.js").
      done( ->
        log "(Internal documents page) javascript was loaded"
        done()).
      fail( (jqxhr, settings, exception) ->
        log "Triggered ajaxError handler"
        log settings
        log exception)

  beforeEach ->
    internal_document_uploader.set('upload_documents',[])

  it 'loads test fixtures and data', ->
    expect($("h1",'.magic-lamp').text()).to.equal "Internal Documents"
    expect($(".internal_document", '.magic-lamp').length).to.equal 10
    expect(typeof(simulant)).to.not.equal("undefined")

  it "fixes document titles for icc accreditation docs", ->
    docs = _(internal_document_uploader.findAllComponents('doc')).select (doc)->doc.get('title').match(/Statement of Compliance/)
    doc_group_id = docs[0].get('document_group_id')
    internal_document_uploader.push('upload_documents',{title : "", document_group_id : doc_group_id, primary : false})
    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[0]
    expect(upload_file.get('title')).to.equal("Statement of Compliance")
    #expect(upload_file.validate_icc_unique()).to.equal(true)
    #expect(upload_file.validate_pending_icc_unique(["statementofcompliance"])).to.equal(true)

  xit "flags as errored when another primary file upload is attempted with duplicate icc file title", ->
    internal_document_uploader.unshift('upload_documents',{title : "Statement of Compliance", fileupload : true, primary : true})
    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[0]
    expect(upload_file.get('is_icc_doc')).to.equal true
    expect(upload_file.validate_icc_unique()).to.equal false
    expect(upload_file.get('duplicate_icc_title_error')).to.equal true
    expect(upload_file.get('fileupload')).to.equal true
    expect(upload_file.duplicate_icc_primary_file()).to.equal true

  xit "does not flag as errored when an icc-titled primary file upload is attempted that does not duplicate existing icc title",->
    internal_document_uploader.unshift('upload_documents',{title : "Enabling Legislation", fileupload : true, primary : true})
    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[0]
    expect(upload_file.get('is_icc_doc')).to.equal true
    expect(upload_file.validate_icc_unique()).to.equal true
    expect(upload_file.get('duplicate_icc_title_error')).to.equal false
    expect(upload_file.get('fileupload')).to.equal true
    expect(upload_file.duplicated_title_with_existing_file()).to.equal false
    expect(upload_file.duplicate_icc_primary_file()).to.equal false

  xit "flags as errored when two primary file uploads are attempted in the same upload with identical icc file titles", ->
    internal_document_uploader.unshift('upload_documents',{title : "Enabling Legislation", fileupload : true, primary : true})
    internal_document_uploader.unshift('upload_documents',{title : "Enabling Legislation", fileupload : true, primary : true})

    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[0]
    expect(upload_file.get('is_icc_doc')).to.equal true
    expect(upload_file.validate_pending_icc_unique(["enablinglegislation","enablinglegislation"])).to.equal false
    expect(upload_file.get('duplicate_icc_title_error')).to.equal true
    expect(upload_file.get('fileupload')).to.equal true
    expect(upload_file.duplicated_title_in_this_upload()).to.equal true

    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[1]
    expect(upload_file.get('is_icc_doc')).to.equal true
    expect(upload_file.validate_pending_icc_unique(["enablinglegislation","enablinglegislation"])).to.equal false
    expect(upload_file.get('duplicate_icc_title_error')).to.equal true
    expect(upload_file.get('fileupload')).to.equal true
    expect(upload_file.duplicated_title_in_this_upload()).to.equal true

  xit "does not flag as errored when two primary file uploads are attempted in the same upload with different icc file titles", ->
    internal_document_uploader.unshift('upload_documents',{title : "Enabling Legislation", fileupload : true, primary : true})
    internal_document_uploader.unshift('upload_documents',{title : "Annual Report", fileupload : true, primary : true})

    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[0]
    expect(upload_file.get('is_icc_doc')).to.equal true
    expect(upload_file.validate_pending_icc_unique(["enablinglegislation","annualreport"])).to.equal true
    expect(upload_file.get('duplicate_icc_title_error')).to.equal false
    expect(upload_file.get('fileupload')).to.equal true
    expect(upload_file.duplicated_title_in_this_upload()).to.equal false

    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[1]
    expect(upload_file.get('is_icc_doc')).to.equal true
    expect(upload_file.validate_pending_icc_unique(["enablinglegislation","annualreport"])).to.equal true
    expect(upload_file.get('duplicate_icc_title_error')).to.equal false
    expect(upload_file.get('fileupload')).to.equal true
    expect(upload_file.duplicated_title_in_this_upload()).to.equal false

  xit "adds an error attribute when a revision of a non-icc file is assigned an icc title", ->
    docs = _(internal_document_uploader.findAllComponents('doc')).select (doc)->!doc.get('title').match(/Statement of Compliance/)
    doc_group_id = docs[0].get('document_group_id')
    internal_document_uploader.push('upload_documents',{title : "", document_group_id : doc_group_id, primary : false})
    upload_file = internal_document_uploader.findAllComponents('uploadDocument')[0]
    upload_file.set('title',"Statement of Compliance")
    expect(upload_file.validate()).to.equal false
    expect(upload_file.get('icc_title_error')).to.equal true

  it "adds an error attribute when a non-icc file is edited to an icc title and a dupe is created", ->
    docs = _(internal_document_uploader.findAllComponents('doc')).select (doc)->!doc.get('title').match(/Statement of Compliance/)
    docs[0].set('title', "Statement of Compliance")
    expect(docs[0].validate()).to.equal false
    expect(docs[0].get('title_error')).to.equal true

  it "adds an error when non-icc archive docis edited to icc title", ->
    docs = _(internal_document_uploader.findAllComponents('doc')).select (doc)->!doc.get('title').match(/Statement of Compliance/)
    archive_doc = docs[0].findAllComponents('archivedoc')[0]
    expect(archive_doc.get('is_icc_doc')).to.equal false
    expect(archive_doc.get('non_icc_document_group')).to.equal true
    expect(archive_doc.validate()).to.equal true
    expect(archive_doc.get('icc_title_error')).to.equal false
    archive_doc.set('title','Statement of Compliance')
    expect(archive_doc.get('is_icc_doc')).to.equal true
    expect(archive_doc.validate()).to.equal false
    expect(archive_doc.get('icc_title_error')).to.equal true
