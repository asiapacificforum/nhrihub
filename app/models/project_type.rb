class ProjectType < ActiveRecord::Base

  has_many :project_project_types, :dependent => :destroy
  has_many :projects, :through => :project_project_types
  belongs_to :mandate

  belongs_to :good_governance_mandate, ->{merge Mandate.good_governance}, :class_name => "Mandate", :foreign_key => :mandate_id
  belongs_to :human_rights_mandate,    ->{merge Mandate.human_rights},    :class_name => "Mandate", :foreign_key => :mandate_id
  belongs_to :siu_mandate,             ->{merge Mandate.siu},             :class_name => "Mandate", :foreign_key => :mandate_id

  scope :good_governance, ->{ joins(:good_governance_mandate) }
  scope :human_rights,    ->{ joins(:human_rights_mandate)    }
  scope :siu,             ->{ joins(:siu_mandate)             }

  def as_json(options={})
    super(:only => [:name, :id])
  end

  def self.mandate_groups
    joins(:mandate).
      select('mandates.key, project_types.*').
      group_by{|pt| I18n.t('activerecord.models.mandate.keys.'+pt.key) }
  end

end
