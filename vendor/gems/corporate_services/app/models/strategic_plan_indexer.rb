# Manages the automatic indexing of PlannedResult, Outcome, Activity, PerformanceIndicator
class StrategicPlanIndexer
  Parents = { :planned_result => :strategic_priority,
              :outcome => :planned_result,
              :activity => :outcome,
              :performance_indicator => :activity,
              :target => :activity }

  attr_accessor :object, :parent
  def self.create(object)
    new(object).next
  end

  def parent
    object.send(Parents[object.class.name.tableize.singularize.to_sym])
  end

  def initialize(object)
    @object = object
  end

  def next
    increment? ? incremented_index : parent_index+'.1'
  end

  private
  def parent_index
    parent.index
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
    instances = parent.send(object.class.name.tableize.to_sym).reload
    instances.last unless instances.blank?
  end
end
