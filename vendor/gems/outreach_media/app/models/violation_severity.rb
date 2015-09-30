require 'ostruct'
class ViolationSeverity < ActiveRecord::Base
  has_many :media_appearances
  DefaultValues = [ OpenStruct.new(:rank => 1, :text => "Extremely minor"),
                    OpenStruct.new(:rank => 2, :text => "Somewhat minor"),
                    OpenStruct.new(:rank => 3, :text => "Moderate"),
                    OpenStruct.new(:rank => 4, :text => "Serious"),
                    OpenStruct.new(:rank => 5, :text => "Severe"),
                    OpenStruct.new(:rank => 6, :text => "Extremely severe"),
                    OpenStruct.new(:rank => 7, :text => "Grave") ]

  def rank_text
    [rank.to_s,text].join(": ")
  end
end
