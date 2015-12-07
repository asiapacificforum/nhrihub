class LocalMetric
  attr_accessor :val, :class_key, :attribute_key
  def initialize(val, class_key, attribute_key)
    @val = val
    @class_key = class_key.to_s
    @attribute_key = attribute_key.to_s
  end

  def to_h
    metric_name = I18n.t("activerecord.attributes.#{class_key}.#{attribute_key}")
    {:name => metric_name, :value => val}
  end
end
