class Nhri::Heading < ActiveRecord::Base
  has_many :human_rights_attributes, :class_name => "Nhri::HumanRightsAttribute", :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :human_rights_attributes, :allow_destroy => true
  has_many :indicators, :dependent => :destroy
  has_many :all_attribute_structural_indicators, ->{ where("nature = 'Structural'").where(:human_rights_attribute_id => nil) }, :class_name => 'Nhri::Indicator'
  has_many :all_attribute_process_indicators,    ->{ where("nature = 'Process'").where(:human_rights_attribute_id => nil) }, :class_name => 'Nhri::Indicator'
  has_many :all_attribute_outcomes_indicators,   ->{ where("nature = 'Outcomes'").where(:human_rights_attribute_id => nil) }, :class_name => 'Nhri::Indicator'

  def as_json(options={})
    default_options = {:except => [:created_at, :updated_at],
                       :methods => [:human_rights_attributes,
                                    :all_attribute_structural_indicators,
                                    :all_attribute_process_indicators,
                                    :all_attribute_outcomes_indicators] }

    options = default_options if options.blank?
    super(options)
  end
end
