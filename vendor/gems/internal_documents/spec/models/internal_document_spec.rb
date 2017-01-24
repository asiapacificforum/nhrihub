require 'rails_helper'

describe "create internal documents without supplying document_group_id" do
  it "should create documents in different groups" do
    expect { 3.times{ FactoryGirl.create(:internal_document) }}.to change{DocumentGroup.count}.by(3)
  end
end

describe "create internal documents and supply document_group_id" do
  before do
    doc = FactoryGirl.create(:internal_document)
    FactoryGirl.create(:internal_document, :document_group_id => doc.document_group_id)
  end

  it "should create documents in the same group" do
    expect( InternalDocument.count ).to eq 2
    expect( InternalDocument.all.map(&:document_group_id).compact.uniq.count ).to eq(1)
  end
end

describe "archive_files" do
  context "when self is a primary file" do
    before do
      @doc = FactoryGirl.create(:internal_document, :revision_major => 3, :revision_minor => 3)
      @same_group = FactoryGirl.create(:internal_document, :document_group_id => @doc.document_group_id, :revision_major => 3, :revision_minor => 2)
      @different_group = FactoryGirl.create(:internal_document, :revision_major => 3, :revision_minor => 2)
    end

    it "should return docs in the same group" do
      expect(@doc.archive_files).to eq([@same_group])
    end
  end

  context "when self is not a primary file" do
    before do
      @doc = FactoryGirl.create(:internal_document, :revision_major => 3, :revision_minor => 2)
      @same_group = FactoryGirl.create(:internal_document, :document_group_id => @doc.document_group_id, :revision_major => 3, :revision_minor => 3)
      @different_group = FactoryGirl.create(:internal_document)
    end

    it "should return empty set" do
      expect(@doc.archive_files).to eq([])
    end
  end
end

describe "automatic revision assigment" do
  context "when document is the first in a new group" do
    it "should assign 1.0 rev" do
      document = FactoryGirl.create(:internal_document, :revision_major => nil, :revision_minor => nil)
      expect(document.reload.revision).to eq "1.0"
    end
  end

  context "when a document is already present in the group" do
    it "should increment the minor rev" do
      document = FactoryGirl.create(:internal_document, :revision_major => nil, :revision_minor => nil)
      new_doc = FactoryGirl.create(:internal_document, :document_group_id => document.document_group_id, :revision_major => nil, :revision_minor => nil)
      expect(new_doc.reload.revision).to eq "1.1"
    end
  end
end

describe "when title is blank" do
  it "assigns filename base as title" do
    document = FactoryGirl.create(:internal_document, :title => '')
    expect(document.title).to eq document.original_filename.split('.')[0]
  end
end

describe "when accreditation required special filename is assigned to non-accreditation-required file" do
  context "and the document was the primary document in its group" do
    before do
      @group = FactoryGirl.create(:accreditation_document_group, :title => "Budget")
      @archive = FactoryGirl.create(:internal_document, :revision_major => nil, :revision_minor => nil)
      @primary = FactoryGirl.create(:internal_document, :document_group_id => @archive.document_group_id, :revision_major => nil, :revision_minor => nil)
      @group_id = @archive.document_group_id
      @primary.update_attributes(:title => "Budget")
    end

    it "should assign the primary and all associated archive files to the accreditation required group" do
      expect(@primary.reload.document_group_id).to eq @group.id
      expect(@archive.reload.document_group_id).to eq @group.id
    end

    it "should convert primary and archive files to AccreditationRequiredDoc type" do
      expect(@primary.reload.type).to eq "AccreditationRequiredDoc"
      expect(InternalDocument.find(@primary.id)).to be_a AccreditationRequiredDoc
      expect(@archive.reload.type).to eq "AccreditationRequiredDoc"
      expect(InternalDocument.find(@archive.id)).to be_a AccreditationRequiredDoc
    end

    it "should assign accreditation required title to archive file" do
      expect(@archive.reload.title).to eq "Budget"
    end

    it "should remove the (now empty) non-accreditation-required document group" do
      expect{DocumentGroup.find(@group_id)}.to raise_error ActiveRecord::RecordNotFound
    end
  end
end

describe "#filetype" do
  it "should decode pdf file as pdf filetype" do
    doc = InternalDocument.create(:original_filename => "foo.pdf")
    expect(doc.filetype).to eq "pdf"
  end

  it "should decode ppt file as ppt filetype" do
    doc = InternalDocument.create(:original_filename => "foo.ppt")
    expect(doc.filetype).to eq "ppt"
  end

  it "should decode doc and docx files as msword filetype" do
    doc = InternalDocument.create(:original_filename => "foo.doc")
    expect(doc.filetype).to eq "msword"
    doc = InternalDocument.create(:original_filename => "foo.docx")
    expect(doc.filetype).to eq "msword"
  end

  it "should decode xls and xlsx files as excel filetype" do
    doc = InternalDocument.create(:original_filename => "foo.xls")
    expect(doc.filetype).to eq "excel"
    doc = InternalDocument.create(:original_filename => "foo.xlsx")
    expect(doc.filetype).to eq "excel"
  end

  it "should decode tiff, jpg, jpeg, and gif files as image filetype" do
    ["tiff","jpg","jpeg","gif"].each do |ext|
      doc = InternalDocument.create(:original_filename => "foo.#{ext}")
      expect(doc.filetype).to eq "image"
    end
  end
end
