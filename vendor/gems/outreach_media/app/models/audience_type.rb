class AudienceType < ActiveRecord::Base
  has_many :outreach_events
  ## included here just for reference, and to initially populate the database with a rake task
  DefaultValues = [ OpenStruct.new(:short_type => nil, :long_type => "Police"),
                    OpenStruct.new(:short_type => "MCIL", :long_type => "Ministry of Commerce, Industry and Labour"),
                    OpenStruct.new(:short_type => "MNRE", :long_type => "Ministry of Natural Resources and Environment"),
                    OpenStruct.new(:short_type => "MWSCD", :long_type => "Ministry of Women, Community and Social Development"),
                    OpenStruct.new(:short_type => "MoF", :long_type => "Ministry of Finance"),
                    OpenStruct.new(:short_type => nil, :long_type => "Schools"),
                    OpenStruct.new(:short_type => "NGO", :long_type => "Non-Government Organization"),
                    OpenStruct.new(:short_type => nil, :long_type => "Other")]

  def as_json(options = {})
    super(:except => [:created_at, :updated_at], :methods => [:text])
  end

  def text
    short_type || long_type
  end
end
