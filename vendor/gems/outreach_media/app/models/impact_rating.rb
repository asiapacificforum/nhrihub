require 'ostruct'
class ImpactRating < ActiveRecord::Base
  has_many :outreach_events
  DefaultValues = [ OpenStruct.new(:rank => 1, :text => "No improved audience understanding"),
                    OpenStruct.new(:rank => 2, :text => "Some improved audience understanding"),
                    OpenStruct.new(:rank => 3, :text => "Improved understanding among half of participants"),
                    OpenStruct.new(:rank => 4, :text => "Improved understanding among most participants"),
                    OpenStruct.new(:rank => 5, :text => "Universal improved understanding") ]

  def rank_text
    [rank.to_s,text].join(": ")
  end
end
