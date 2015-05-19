require 'rails_helper'

describe "create internal documents without supplying document_group_id" do
  before do
    FactoryGirl.create(:internal_document)
    FactoryGirl.create(:internal_document)
  end

  it "should create documents in different groups" do
    expect( InternalDocument.count ).to eq 2
    # no nils and all different:
    expect( InternalDocument.all.map(&:document_group_id).compact.uniq.count ).to eq(InternalDocument.count)
  end
end

describe "create internal documents and supply document_group_id" do
  before do
    doc = FactoryGirl.create(:internal_document)
    FactoryGirl.create(:internal_document, :document_group_id => doc.id)
  end

  it "should create documents in different groups" do
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
