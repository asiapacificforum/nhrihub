class Nhri::ComplaintBasis < Convention
  include NamedList
  DefaultNames = CONVENTIONS.keys
  def self.i18n_key
    :human_rights
  end
end
