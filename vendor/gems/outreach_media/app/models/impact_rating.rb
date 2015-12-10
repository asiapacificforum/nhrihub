require 'ostruct'
class ImpactRating < ActiveRecord::Base
  has_many :outreach_events
  # default values included here as a reference
  # used in a rake task to prepopulate the database table
  DefaultValues = [ OpenStruct.new(:rank => 1, :text =>  "No improved audience understanding"),
                    OpenStruct.new(:rank => 2, :text =>  "Some improved audience understanding"),
                    OpenStruct.new(:rank => 3, :text =>  "Improved understanding among half of participants"),
                    OpenStruct.new(:rank => 4, :text =>  "Improved understanding among most participants"),
                    OpenStruct.new(:rank => 5, :text =>  "Universal improved understanding") ]






  def as_json(options = {})
    super(:except => [:created_at, :updated_at])
  end
end
