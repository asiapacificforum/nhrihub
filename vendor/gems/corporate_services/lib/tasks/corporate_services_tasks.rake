# desc "Explaining what the task does"
# task :corporate_services do
#   # Task goes here
# end
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

namespace :corporate_services do
  desc "re-initialize database with internal documents: 5 primary, 10 archive"
  task :populate_id => :environment do
    DocumentGroup.delete_all
    InternalDocument.delete_all
    Organization.delete_all

    5.times do
      current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
      doc = FactoryGirl.create(:internal_document, :revision => first_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      #doc = FactoryGirl.create(:internal_document, :revision => first_doc_rev.to_s, :title => "one", :original_filename => rand_filename)
      dgid = doc.document_group_id
      #first_archive_rev = (rand(30)+20).to_f/10
      #first_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => first_archive_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      #second_archive_rev = (rand(20)).to_f/10
      #second_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => second_archive_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      words = ["two","three","four","five","six","seven","eight","nine","ten","eleven"]
      5.times do |i|
        current_doc_rev -= 0.1
        current_doc_rev = current_doc_rev.round(1)
        FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => current_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
        #FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => current_doc_rev.to_s, :title => words[i], :original_filename => rand_filename)
      end
    end
  end

  desc "re-initialize strategic priorities"
  task :populate_sp => :environment do
    StrategicPriority.delete_all
    PlannedResult.delete_all
    Outcome.delete_all
    Activity.delete_all
    PerformanceIndicator.delete_all

    2.times do |i|
      sp = FactoryGirl.create(:strategic_priority, :priority_level => i+1)
      2.times do
        pr = FactoryGirl.create(:planned_result, :strategic_priority => sp)
        2.times do
          o = FactoryGirl.create(:outcome, :planned_result => pr)
          2.times do
            a = FactoryGirl.create(:activity, :outcome => o)
            2.times do
              FactoryGirl.create(:performance_indicator, :activity => a)
            end
          end
        end
      end
    end
  end
end
