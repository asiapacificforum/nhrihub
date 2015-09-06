class Filetype
  include ActiveModel::Model
  attr_accessor :ext

  validate :instance_validations

  def initialize(attrs={})
    @ext = attrs[:ext]
  end

  #TODO client-side validations would be better
  def instance_validations
    if !ext
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.blank')
    elsif ext.length < 2
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.too_short')
    elsif ext.length > 4
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.too_long')
    elsif SiteConfig[@site_config_key].include? ext
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.duplicate')
    end
  end

  def self.create(val)
    val = val.match(/\w+/) if val
    val = val[0].downcase if val
    filetype = new(:ext=>val)
    if filetype.valid?
      filetypes = SiteConfig[@site_config_key] << val
      SiteConfig[@site_config_key] = filetypes
    end
    filetype
  end
end
