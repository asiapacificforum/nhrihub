class Nhri::ComplaintBasis < Convention
  has_many :complaint_human_rights_complaint_bases
  include NamedList
  DefaultNames = CONVENTIONS.keys
  def self.i18n_key
    :human_rights
  end
end
