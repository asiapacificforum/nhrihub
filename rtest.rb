module ParentModule
  def link_to
    "original link_to"
  end
end

module FixitModule
  def link_to
    "link_to_with_pc"
  end
end

module ParentModule
  alias_method :link_to_without_permission_check, :link_to # link_to_without_permission_check points to ORIGINAL, in parent
  prepend FixitModule # link_to is intercepted by Fixit
  alias_method :link_to_with_permission_check, :link_to # link_to_with_permission_check intercepted by Fixit link_to
end

class BaseClass
  include ParentModule
end

puts BaseClass.new.link_to
puts BaseClass.new.link_to_with_permission_check
puts BaseClass.new.link_to_without_permission_check


