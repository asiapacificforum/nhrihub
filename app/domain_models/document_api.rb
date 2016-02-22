require 'active_support/concern'
module DocumentApi
  extend ActiveSupport::Concern

  def formatted_modification_date
    lastModifiedDate.to_s
  end

  def formatted_creation_date
    created_at.to_s
  end

  def formatted_filesize
    ActiveSupport::NumberHelper.number_to_human_size(filesize)
  end
end
