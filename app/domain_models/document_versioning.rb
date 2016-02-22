require 'active_support/concern'
module DocumentVersioning
  extend ActiveSupport::Concern

  def <=>(other)
    [revision_major, revision_minor] <=> [other.revision_major, other.revision_minor]
  end

  def revision
    revs = [revision_major, revision_minor]
    revs.join('.') unless revs.all?(&:blank?)
  end

  def revision=(val)
    self.revision_major, self.revision_minor = val.split('.').map(&:to_i) if val
  end

  def has_revision?
    revision_major.is_a?(Integer)
  end

  def next_minor_revision
    [revision_major, revision_minor.succ].join('.')
  end
end
