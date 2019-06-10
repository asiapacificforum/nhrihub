require "webpacker/helper"

module Complaints
  module ApplicationHelper
    include ::Webpacker::Helper

    def current_webpacker_instance
      Complaints.webpacker
    end
  end
end
