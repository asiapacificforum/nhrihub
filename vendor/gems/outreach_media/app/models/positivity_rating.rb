#require 'ostruct'
class PositivityRating < ActiveRecord::Base
  has_many :media_appearances
  # default values included here as a reference
  # used in a rake task to prepopulate the database table
  DefaultValues = [ OpenStruct.new(:rank => 1),
                    OpenStruct.new(:rank => 2),
                    OpenStruct.new(:rank => 3),
                    OpenStruct.new(:rank => 4),
                    OpenStruct.new(:rank => 5) ]

  include OutreachMediaMetric
end
