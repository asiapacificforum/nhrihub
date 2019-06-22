require "webpacker/helper"

module Complaints
  module ApplicationHelper
    include ::Webpacker::Helper

    def webpacker_instance(name)
      if name == "complaints"
        Complaints.webpacker
      else
        Webpacker.instance
      end
    end

    def javascript_pack_tag(name)
      javascript_include_tag(webpacker_instance(name).manifest.lookup!(name, type: :javascript))
    end
  end
end
