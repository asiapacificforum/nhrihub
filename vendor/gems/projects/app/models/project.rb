class Project < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  has_many :project_performance_indicators, :dependent => :destroy
  has_many :performance_indicators, :through => :project_performance_indicators
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :project_mandates, :dependent => :destroy
  has_many :mandates, :through => :project_mandates
  has_many :project_project_types, :dependent => :destroy
  has_many :project_types, :through => :project_project_types
  has_many :good_governance_project_types, ->{merge(ProjectType.good_governance)}, :through => :project_project_types, :source => :project_type
  has_many :human_rights_project_types,    ->{merge(ProjectType.human_rights)},    :through => :project_project_types, :source => :project_type
  has_many :siu_project_types,             ->{merge(ProjectType.siu)},             :through => :project_project_types, :source => :project_type
  has_many :project_documents, :dependent => :destroy
  has_many :named_project_documents, ->{merge(ProjectDocument.named)}, :class_name => 'ProjectDocument', :dependent => :destroy
  accepts_nested_attributes_for :project_documents

  accepts_nested_attributes_for :project_performance_indicators
  alias_method :performance_indicator_associations_attributes=, :project_performance_indicators_attributes=

  # name was changed in the UI, but model name was not changed as there is an Area model already
  alias_method :area_ids=, :mandate_ids=
  alias_method :area_ids, :mandate_ids
  alias_method :areas, :mandates
  alias_method :areas=, :mandates=

  def as_json(options={})
    if options.blank?
      {:id => id,
       :title => title,
       :description => description,
       :project_types => project_mandate_types, # this is why I can't use the normal as_json technique!
                                                # [{"name"=>"mandate name", "project_types"=>[{"id"=>1, "name"=>"type name"}]}]
       :area_ids => area_ids,
       :areas => areas,
       :project_type_ids => project_type_ids,
       :reminders => reminders,
       :notes => notes,
       :project_documents => project_documents,
       :performance_indicator_associations => performance_indicator_associations }
    else
      super(options)
    end
  end

  def performance_indicator_associations
    project_performance_indicators
  end

  def project_mandate_types
    Mandate.project_types_for(id)
  end

  # overwrite the AR method for special treatment of named documents
  def save
    if named_project_documents.length #there are existing named docs
      new_doc_titles = project_documents.reject(&:persisted?).map(&:title)
      # delete any existing named docs that are being added with this update
      named_project_documents.
        select { |doc| new_doc_titles.include? doc.title }.
        each { |doc| doc.destroy }
    end
    super
  end

  def notable_url(notable_id)
    project_note_path('en',id,notable_id)
  end

  def remindable_url(remindable_id)
    project_reminder_path('en',id,remindable_id)
  end

  def index_url
    projects_path(:en, {:title => title})
  end

end
