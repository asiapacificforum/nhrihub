require 'active_support/concern'
module StrategicPlanIndex
  extend ActiveSupport::Concern
  included do
    default_scope ->{ order("string_to_array(index,'.')::int[]") }
  end

  def <=>(other)
    self.index.split('.').map(&:to_i) <=> other.index.split('.').map(&:to_i)
  end

  def >=(other)
    [0,1].include?(self <=> other)
  end

  def create_index
    increment? ? incremented_index : parent_index+'.1'
  end

  def decrement_index
    ar = index.split('.')
    new_suffix = ar.pop.to_i.pred.to_i
    ar << new_suffix
    new_index = ar.join('.')
    update_attribute(:index, new_index)
    index_descendant.each{|o| o.decrement_index_prefix(new_index)}
  end

  def increment_index_root
    ar = index.split('.')
    ar[0] = ar[0].to_i.succ.to_s
    new_index = ar.join('.')
    update_attribute(:index, new_index)
    index_descendant.each{|a| a.increment_index_root}
  end

  def decrement_index_prefix(new_prefix)
    ar = index.split('.')
    new_index = [new_prefix,ar[-1]].join('.')
    update_attribute(:index, new_index)
    index_descendant.each{|o| o.decrement_index_prefix(new_index)}
  end

  def indexed_description
    if description.blank?
      ""
    else
      [index, description].join(' ')
    end
  end

  private
  def parent_index
    index_parent.index
  end

  def increment?
    previous_instance && previous_instance.index.gsub(/\.\d*$/,'') == parent_index
  end

  def incremented_index
    ar = previous_instance.index.split('.')
    ar[-1] = ar[-1].to_i.succ.to_s
    ar.join('.')
  end

  def previous_instance
    instances = index_parent.send(self.class.name.tableize.to_sym).reload
    instances.last unless instances.blank?
  end
end
