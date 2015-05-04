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
      @doc = FactoryGirl.create(:internal_document, :primary)
      @same_group = FactoryGirl.create(:internal_document, :archive, :document_group_id => @doc.document_group_id)
      @different_group = FactoryGirl.create(:internal_document, :archive)
    end

    it "should return docs in the same group" do
      expect(@doc.archive_files).to eq([@same_group])
    end
  end

  context "when self is not a primary file" do
    before do
      @doc = FactoryGirl.create(:internal_document, :archive)
      @same_group = FactoryGirl.create(:internal_document, :archive, :document_group_id => @doc.document_group_id)
      @different_group = FactoryGirl.create(:internal_document, :archive)
    end

    it "should return empty set" do
      expect(@doc.archive_files).to eq([])
    end
  end
end

describe "inheritor" do
  context "when revision values are present" do
    before do
      @primary = FactoryGirl.create(:internal_document, :primary)
      dgi = @primary.document_group_id
      @archive1 = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgi, :revision => "4.1")
      @archive2 = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgi, :revision => "3.0")
    end

    it "should return the archive file with the highest revision value" do
      expect(@primary.inheritor).to eq @archive1
    end
  end

  context "when two of the archive revision values are the same" do
    before do
      @primary = FactoryGirl.create(:internal_document, :primary)
      dgi = @primary.document_group_id
      @archive1 = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgi, :revision => "4.1", :created_at => 1.week.ago)
      @archive2 = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgi, :revision => "4.1", :created_at => 2.weeks.ago)
    end

    it "should return the archive file with the most recent created_at date" do
      expect(@primary.inheritor).to eq @archive1
    end
  end

  context "when some revision values are missing" do
    before do
      @primary = FactoryGirl.create(:internal_document, :primary)
      dgi = @primary.document_group_id
      @archive1 = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgi, :revision => "4.1")
      @archive2 = FactoryGirl.create(:internal_document, :archive, :null_revision, :document_group_id => dgi)
    end

    it "should return the archive file with the highest non-null revision value" do
      expect(@primary.inheritor).to eq @archive1
    end
  end

  context "when all revision values are missing" do
    before do
      @primary = FactoryGirl.create(:internal_document, :primary)
      dgi = @primary.document_group_id
      @archive1 = FactoryGirl.create(:internal_document, :archive, :null_revision, :document_group_id => dgi, :created_at => 1.week.ago)
      @archive2 = FactoryGirl.create(:internal_document, :archive, :null_revision, :document_group_id => dgi, :created_at => 2.weeks.ago)
    end

    it "should return the archive file with the highest non-null revision value" do
      expect(@primary.inheritor).to eq @archive1
    end
  end
end

describe "delete primary with archive_files" do
  before do
    @primary = FactoryGirl.create(:internal_document, :primary)
    dgi = @primary.document_group_id
    @archive1 = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgi, :revision => "4.1")
    @archive2 = FactoryGirl.create(:internal_document, :archive, :document_group_id => dgi, :revision => "3.0")
    @primary.destroy
    @archive1.reload
    @archive2.reload
  end

  it "should return the archive file with the highest revision value" do
    expect(@archive1.primary).to be true
    expect(@archive2.primary).to be false
  end
end
