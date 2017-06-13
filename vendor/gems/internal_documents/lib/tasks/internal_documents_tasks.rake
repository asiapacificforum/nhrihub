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
  arr.join('_').downcase + ".docx"
end

namespace :internal_documents do
  task :depopulate => :environment do
    DocumentGroup.destroy_all
    InternalDocument.destroy_all
  end

  desc "populate database with internal documents: 5 primary, 10 archive"
  task :populate => "internal_documents:depopulate" do
    5.times do
      current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
      doc = FactoryGirl.create(:internal_document, :revision => first_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      dgid = doc.document_group_id
      words = ["two","three","four","five","six","seven","eight","nine","ten","eleven"]
      5.times do |i|
        current_doc_rev -= 0.1
        current_doc_rev = current_doc_rev.round(1)
        FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => current_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      end
    end
  end
end

