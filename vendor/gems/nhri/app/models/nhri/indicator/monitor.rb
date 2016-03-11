class Nhri::Indicator::Monitor < ActiveRecord::Base
  belongs_to :indicator

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => [:val])
  end

  def val
    case format # either "percent", "int" or "text"
    when "percent"
      "#{description}: #{value}%"
    when "int"
      "#{description}: #{value}"
    else
      description
    end
  end

end
