class CaseReferenceCollection
  attr_accessor :refs

  def initialize(refs)
    @refs = refs.map{|cr| CaseReference.new(cr)}
  end

  def highest_ref
    @refs.sort.last unless @refs.empty?
  end

  def next_ref
    if highest_ref
      highest_ref.next_ref
    else
      CaseReference.new().next_ref
    end
  end

end
