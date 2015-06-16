#json.file do
  #json.partial! 'files', :locals => {:internal_documents => [@internal_document]}
  json.partial! 'file', :locals => {:internal_document => @internal_document}

  json.archive_files @internal_document.archive_files do |archive|
    json.partial! 'file', :locals => {:internal_document => archive}
  end
#end
