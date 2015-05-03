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
  before do
    @doc = FactoryGirl.create(:internal_document)
    @same_group = FactoryGirl.create(:internal_document, :document_group_id => @doc.id)
    @different_group = FactoryGirl.create(:internal_document)
  end

  it "should return docs in the same group" do
    expect(@doc.archive_files).to eq([@same_group])
  end
end
