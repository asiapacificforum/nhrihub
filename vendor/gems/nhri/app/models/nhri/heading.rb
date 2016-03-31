class Nhri::Heading < ActiveRecord::Base
  has_many :offences, :class_name => "Nhri::Offence", :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :offences, :allow_destroy => true
  has_many :indicators, :dependent => :destroy
  has_many :all_offence_structural_indicators, ->{ where("nature = 'Structural'").where(:offence_id => nil) }, :class_name => 'Nhri::Indicator'
  has_many :all_offence_process_indicators,    ->{ where("nature = 'Process'").where(:offence_id => nil) }, :class_name => 'Nhri::Indicator'
  has_many :all_offence_outcomes_indicators,   ->{ where("nature = 'Outcomes'").where(:offence_id => nil) }, :class_name => 'Nhri::Indicator'

  def as_json(options={})
    default_options = {:except => [:created_at, :updated_at],
                       :methods => [:offences,
                                    :all_offence_structural_indicators,
                                    :all_offence_process_indicators,
                                    :all_offence_outcomes_indicators] }

    options = default_options if options.blank?
    super(options)
  end
end
