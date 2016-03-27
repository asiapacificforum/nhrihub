class Nhri::FileMonitor < ActiveRecord::Base
  include DocumentApi
  PermittedAttributes = [:indicator_id, :file, :original_filename, :original_type, :filesize]
  belongs_to :indicator
  belongs_to :user

  alias_method :author, :user

  attachment :file

  default_scope ->{ order(:created_at => :asc) }

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => [:author,
                                                              :formatted_modification_date, # from DocumentApi
                                                              :formatted_creation_date, # ditto
                                                              :formatted_filesize ]) # ditto
  end

end
