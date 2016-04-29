class Project < ActiveRecord::Base
  has_many :project_performance_indicators, :dependent => :destroy
  has_many :performance_indicators, :through => :project_performance_indicators
  has_many :project_conventions, :dependent => :destroy
  has_many :conventions, :through => :project_conventions
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :project_mandates, :dependent => :destroy
  has_many :mandates, :through => :project_mandates
  has_many :project_project_types, :dependent => :destroy
  has_many :project_types, :through => :project_project_types
  has_many :project_agencies, :dependent => :destroy
  has_many :agencies, :through => :project_agencies

  def as_json(options={})
    if options.blank?
      {:id => id,
       :title => title,
       :description => description,
       :project_types => project_mandate_types, # this is why I can't use the normal as_json technique!
                                                # [{"name"=>"mandate name", "types"=>[{"id"=>1, "name"=>"type name"}]}]
       :mandate_ids => mandate_ids,
       :mandates => mandates,
       :agencies => agencies,
       :agency_ids => agency_ids,
       :conventions => conventions,
       :convention_ids => convention_ids,
       :project_type_ids => project_type_ids,
       :reminders => reminders,
       :notes => notes,
       :performance_indicator_ids => performance_indicator_ids }
    else
      super(options)
    end
  end

  def project_mandate_types
    Mandate.project_types_for(id)
  end
end
