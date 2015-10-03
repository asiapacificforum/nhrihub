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
  task :init => :environment do
    DocumentGroup.delete_all
    InternalDocument.delete_all

    5.times do
      first_doc_rev = (rand(49)+50).to_f/10
      doc = FactoryGirl.create(:internal_document, :revision => first_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      dgid = doc.document_group_id
      first_archive_rev = (rand(30)+20).to_f/10
      first_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => first_archive_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      second_archive_rev = (rand(20)).to_f/10
      second_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => second_archive_rev.to_s, :title => rand_title, :original_filename => rand_filename)
    end
  end
end
