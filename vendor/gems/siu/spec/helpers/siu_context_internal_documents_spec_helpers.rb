require 'rspec/core/shared_context'

module SiuContextInternalDocumentsSpecHelpers
  extend RSpec::Core::SharedContext
  def populate_database
    current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
    doc = FactoryGirl.create(:siu_internal_document,
                             :revision => first_doc_rev.to_s,
                             :title => Faker::Lorem.words(4).join(' '),
                             :original_filename => Faker::Lorem.words(3).join('_')+'.doc')
    dgid = doc.document_group_id
    4.times do |i|
      current_doc_rev -= 0.1
      current_doc_rev = current_doc_rev.round(1)
      FactoryGirl.create(:siu_internal_document,
                         :document_group_id => dgid,
                         :revision => current_doc_rev.to_s,
                         :title => Faker::Lorem.words(4).join(' '),
                         :original_filename => Faker::Lorem.words(3).join('_')+'.doc')
    end
  end

  def index_path
    siu_internal_documents_path('en')
  end

  def navigation_menu_text
    "Special Investigations Unit"
  end

  def heading_prefix
    "Special Investigations Unit"
  end

  def document_model
    Siu::InternalDocument
  end

  def create_a_document(**options)
    revision_major, revision_minor = options.delete(:revision).split('.') if options && options[:revision]
    options = options.merge({:revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9)})
    doc = FactoryGirl.create(:siu_internal_document, options)
  end

  def create_a_document_in_the_same_group(**options)
    revision_major, revision_minor = options.delete(:revision).to_s.split('.') if options && options[:revision]
    group_id = @doc.document_group_id
    options = options.merge({ :revision_major => revision_major || rand(9), :revision_minor => revision_minor || rand(9), :document_group_id => group_id})
    FactoryGirl.create(:siu_internal_document, options)
  end
end

