class Filetype
  include ActiveModel::Model
  attr_accessor :ext, :model

  validate :instance_validations

  def initialize(attrs={})
    @ext = attrs[:ext]
    @model = attrs[:model]
  end

  #TODO client-side validations would be better
  def instance_validations
    if !ext
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.blank')
    elsif ext.length < 2
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.too_short')
    elsif ext.length > 4
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.too_long')
    elsif model.permitted_filetypes.include? ext
      errors.add :ext, I18n.t('activemodel.errors.models.filetype.duplicate')
    end
  end

  def self.create(val,model)
    ext = val[:ext]
    ext = ext.match(/\w+/) if ext
    ext = ext[0].downcase if ext
    filetype = new(:ext=>ext, :model => model)
    if filetype.valid?
      filetypes = model.permitted_filetypes << ext
      model.permitted_filetypes = filetypes
    end
    filetype
  end
end
