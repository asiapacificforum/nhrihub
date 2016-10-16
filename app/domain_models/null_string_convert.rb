class NullStringConvert
  def self.before_save(object)
    klass = object.class.name.constantize
    string_columns = klass.columns.select{|c| c.type == :string || c.type == :text}
    string_columns.each do |column|
      column_name = column.name.to_sym
      value = object.send(column_name)
      object.write_attribute(column_name, nil) if "null" == value
    end
  end
end
