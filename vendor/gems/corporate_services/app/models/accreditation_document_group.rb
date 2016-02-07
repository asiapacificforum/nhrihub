class AccreditationDocumentGroup < DocumentGroup
  # an array of hashes
  # each hash with required doc title and
  # either the AccreditationDocumentGroup id or nil
  def self.all_possible
    persisted = all.collect(&:id_and_title)
    not_persisted_titles = AccreditationRequiredDoc::DocTitles - persisted.collect{|adg| adg[:title]}
    not_persisted = not_persisted_titles.collect{|npt| {:document_group_id => nil, :title => npt}}
    persisted + not_persisted
  end

  def id_and_title
    {:document_group_id => id, :title => primary.title}
  end
end
