class StrategicPlanIndexer
  attr_accessor :object, :parent
  def initialize(object,parent)
    @object, @parent = object, parent
  end

  def next
    increment? ?  incremented_index : parent_index+".1"
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
    ar[-1] = ar[1].to_i.succ.to_s
    ar.join('.')
  end

  def previous_instance
    object.class.name.constantize.send(:last)
  end
end
