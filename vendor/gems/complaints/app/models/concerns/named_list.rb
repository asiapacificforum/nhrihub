module NamedList
  extend ActiveSupport::Concern
  module ClassMethods
    def named_list
      [ [:key , i18n_key],
        [:name, I18n.t("activerecord.models.mandate.keys.#{i18n_key}") ],
        [:collection, "#{i18n_key}_complaint_basis_ids"],
        [:complaint_bases, all] ]
    end
  end
end
