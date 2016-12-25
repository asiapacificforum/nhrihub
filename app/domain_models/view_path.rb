require 'active_support/concern'
module ViewPath
  extend ActiveSupport::Concern

  def to_xml
    xml
  end

  def template(name)
    File.read(Root.join(TEMPLATE_PATH,name))
  end
end
