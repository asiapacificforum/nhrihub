class DocumentGroup < ActiveRecord::Base
  has_many :internal_documents

  def primary
    internal_documents.last
  end

  def next_minor_revision
    if internal_documents.empty?
      "1.0"
    else
      [primary.revision_major, primary.revision_minor.succ].join('.')
    end
  end

  def empty?
    internal_documents.count.zero?
  end
end
