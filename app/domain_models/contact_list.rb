require 'contact'
# used for serialized contacts column in Organization model
class ContactList
  attr_accessor :contacts

  def initialize(contacts = []) # e.g [{:phone => "555-1212"},{:phone => "888-2347"}]
    @contacts = contacts.map{|c| Contact.new(c)}
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
