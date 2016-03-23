class Nhri::Heading < ActiveRecord::Base
  has_many :offences
  has_many :indicators
  has_many :all_offence_structural_indicators, ->{ where("nature = 'Structural'").where(:offence_id => nil) }, :class_name => 'Nhri::Indicator'
  has_many :all_offence_process_indicators,    ->{ where("nature = 'Process'").where(:offence_id => nil) }, :class_name => 'Nhri::Indicator'
  has_many :all_offence_outcomes_indicators,   ->{ where("nature = 'Outcomes'").where(:offence_id => nil) }, :class_name => 'Nhri::Indicator'

  def self.create_url
    Rails.application.routes.url_helpers.nhri_headings_path(:en)
  end

  def url
    Rails.application.routes.url_helpers.nhri_heading_path(:en,id) if persisted?
  end

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