class Contact
  include ActiveModel::Model
  include ActiveSupport::NumberHelper
  attr_accessor :phone
  def initialize(attrs = {})
    attrs = attrs.stringify_keys
    @phone = attrs["phone"]
  end

  def to_s
    number_to_phone(phone, :area_code => true)
  end
end
