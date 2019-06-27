require 'active_support/concern'

class Complaint < ActiveRecord::Base
  module Cache
    extend ActiveSupport::Concern
    def cache_key
      "complaint_#{id}_#{updated_at.strftime("%s.%6L")}"
    end

    def cache_identifier
      {cache_key => id}
    end

    module ClassMethods
      def cache_identifiers
        select(:id, :updated_at).map(&:cache_identifier).inject({},:merge)
      end
    end
  end
end
