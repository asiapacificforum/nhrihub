class InternalDocumentSeed
  def self.rand_title
    l = rand(4)+4
    Faker::Lorem.words(l).join(' ')
  end

  def self.rand_filename
    l = rand(3)+3
    Faker::Lorem.words(l).join('_').downcase + ".pdf"
  end

  def self.populate_test_data
    5.times do
      current_doc_rev = first_doc_rev = (rand(49)+50).to_f/10
      doc = FactoryGirl.create(:internal_document, :revision => first_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      ##doc = FactoryGirl.create(:internal_document, :revision => first_doc_rev.to_s, :title => "one", :original_filename => rand_filename)
      #dgid = doc.document_group_id
      ##first_archive_rev = (rand(30)+20).to_f/10
      ##first_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => first_archive_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      ##second_archive_rev = (rand(20)).to_f/10
      ##second_archive = FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => second_archive_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      #words = ["two","three","four","five","six","seven","eight","nine","ten","eleven"]
      #5.times do |i|
      #current_doc_rev -= 0.1
      #current_doc_rev = current_doc_rev.round(1)
      #FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => current_doc_rev.to_s, :title => rand_title, :original_filename => rand_filename)
      ##FactoryGirl.create(:internal_document, :document_group_id => dgid, :revision => current_doc_rev.to_s, :title => words[i], :original_filename => rand_filename)
      #end
    end

  end
end
