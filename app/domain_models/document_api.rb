require 'active_support/concern'
module DocumentApi
  extend ActiveSupport::Concern

  included do
    before_save do |doc|
      if doc.respond_to?(:lastModifiedDate) && !doc.lastModifiedDate
        doc.lastModifiedDate = DateTime.now
      end
    end
  end

  def formatted_modification_date
    lastModifiedDate.to_date.to_s
  end

  def formatted_creation_date
    created_at.to_date.to_s
  end

  def formatted_filesize
    ActiveSupport::NumberHelper.number_to_human_size(filesize)
  end
end
