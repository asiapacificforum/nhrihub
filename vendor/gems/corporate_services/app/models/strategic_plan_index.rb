require 'active_support/concern'
module StrategicPlanIndex
  extend ActiveSupport::Concern

  def <=>(other)
    self.index.split('.').map(&:to_i) <=> other.index.split('.').map(&:to_i)
  end

  def >=(other)
    [0,1].include?(self <=> other)
  end

  def decrement_index
    ar = index.split('.')
    new_suffix = ar.pop.to_i.pred.to_i
    ar << new_suffix
    new_index = ar.join('.')
    update_attribute(:index, ar.join('.'))
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
end
