require 'contact'
# used for serialized contacts column in Organization model
class ContactList
  # contacts is an array of Contact objects
  def initialize(contacts = [])
    @contacts = contacts
  end

  def []index
    @contacts[index]
  end

  def length
    @contacts.length
  end

  def each(&block)
    @contacts.each{|c| block.call(c) }
  end

  def map(&block)
    @contacts.map{|c| block.call(c) }
  end

  def to_s
    @contacts.map(&:to_s).join("<br/>").html_safe
  end

  def empty?
    length.zero?
  end
end
