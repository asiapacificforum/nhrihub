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

  def receives_next_major_rev
    self.revision_major = self.class.highest_major_rev.to_i.succ
    self.revision_minor = 0
  end

  module ClassMethods
    def highest_major_rev
      pluck(:revision_major).max
    end
  end
end
