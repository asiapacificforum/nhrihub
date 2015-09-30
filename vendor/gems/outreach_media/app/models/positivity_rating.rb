#require 'ostruct'
class PositivityRating < ActiveRecord::Base
  has_many :media_appearances
  DefaultValues = [ OpenStruct.new(:rank => 1, :text => "Reflects very negatively on the office"),
                    OpenStruct.new(:rank => 2, :text => "Reflects slightly negatively on the office"),
                    OpenStruct.new(:rank => 3, :text => "Has no bearing on the office"),
                    OpenStruct.new(:rank => 4, :text => "Reflects slightly positively on the office"),
                    OpenStruct.new(:rank => 5, :text => "Reflects very positively on the office") ]

  def rank_text
    [rank.to_s,text].join(": ")
  end
end
