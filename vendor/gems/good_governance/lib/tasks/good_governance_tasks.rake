require 'wordlist'

def rand_title
  l = rand(4)+4
  arr = []
  l.times do
    word = @words.sample
    word = word.upcase == word ? word : word.capitalize
    arr << word
  end
  arr.join(' ')
end

def rand_filename
  l = rand(3)+3
  arr = []
  l.times do
    arr << @words.sample
  end
  arr.join('_').downcase + ".pdf"
end

namespace :good_governance do
  desc "populate all models within the good governance module"
  task :populate => [:populate_id, :populate_proj]

  desc "re-initialize database with internal documents: 5 primary, 10 archive"
  task :populate_id => :environment do
    GoodGovernance::DocumentGroup.destroy_all
    GoodGovernance::InternalDocument.destroy_all

    5.times do
      current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
      doc = FactoryGirl.create(:good_governance_internal_document, :revision => first_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      dgid = doc.document_group_id
      words = ["two","three","four","five","six","seven","eight","nine","ten","eleven"]
      5.times do |i|
        current_doc_rev -= 0.1
        current_doc_rev = current_doc_rev.round(1)
        FactoryGirl.create(:good_governance_internal_document, :document_group_id => dgid, :revision => current_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      end
    end
  end

  desc "populate database with 5 good governance projects"
  task :populate_proj => ["projects:populate", "corporate_services:populate_sp"] do
    GoodGovernance::Project.destroy_all
    mandates = Mandate.all
    m_count = proc {rand(2)+1}

    project_types = ProjectType.all
    pt_count = proc { rand(project_types.count) + 1 }

    agencies = Agency.all
    a_count = proc {rand(agencies.count)+1}

    conventions = Convention.all
    c_count = proc {rand(conventions.count)+1}

    pi = PerformanceIndicator.all
    pi_count = proc {rand(pi.count/2)+1}

    5.times do
      project = FactoryGirl.create(:good_governance_project)

      mandate_count = m_count.call
      project.mandates = mandates.sample(mandate_count)

      project_type_count = pt_count.call
      project.project_types = project_types.sample(project_type_count)

      agency_count = a_count.call
      project.agencies = agencies.sample(agency_count)

      convention_count = c_count.call
      project.conventions = conventions.sample(convention_count)

      performance_indicator_count = pi_count.call
      project.performance_indicators = pi.sample(performance_indicator_count)

      project.save
    end
  end

end
