class Organization < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper

  validates :name, presence: true
  validates :name, uniqueness: {message: "already exists, referrer name must be unique."}

  def <=>(other)
    name.downcase <=> other.name.downcase
  end
end
