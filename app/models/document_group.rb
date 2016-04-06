class DocumentGroup < ActiveRecord::Base
  has_many :internal_documents

  default_scope { order("created_at desc") }

  scope :non_empty, ->{ where("archive_doc_count > 0") }
  scope :empty, ->{ where("archive_doc_count = 0") }

  def primary
    internal_documents.last
  end

  def next_minor_revision
    if empty?
      "1.0"
    else
      primary.next_minor_revision
    end
  end

  def empty?
    archive_doc_count.zero?
  end
end
