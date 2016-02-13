require 'rails_helper'

describe "create the first document in an accreditation_document_group" do
  it "should create a new accreditation document group" do
    document = FactoryGirl.create(:accreditation_required_document, :title => "Statement of Compliance")
    expect(document.accreditation_document_group).to be_a AccreditationDocumentGroup
  end
end

describe "edit a document, creating an icc accreditation document" do
  context "the icc accreditation document group already exists" do
    before do
      @document3 = FactoryGirl.create(:internal_document, :revision=>"1.0")
      @document2 = FactoryGirl.create(:internal_document, :revision=>"1.1", :document_group_id => @document3.document_group_id)
      @document1 = FactoryGirl.create(:internal_document, :revision=>"1.2", :document_group_id => @document2.document_group_id)
      @icc_doc = FactoryGirl.create(:accreditation_required_document, :title => "Statement of Compliance")
      @icc_group_id = @icc_doc.document_group_id
    end

    it "should create two document groups," do
      expect(DocumentGroup.count).to eq 2
      expect(DocumentGroup.all.map(&:type)).to include nil
      expect(DocumentGroup.all.map(&:type)).to include "AccreditationDocumentGroup"
      expect(@document1.document_group.type).to eq nil
      expect(@document2.document_group.type).to eq nil
      expect(@document3.document_group.type).to eq nil
      expect(@icc_doc.document_group.type).to eq "AccreditationDocumentGroup"
    end

    it "should add the document to the existing document group" do
      @document1.update_attribute(:title, "Statement of Compliance")
      expect(@document1.reload.document_group_id).to eq @icc_group_id
    end

    it "should change archive docs titles to match icc title" do
      @document1.update_attribute(:title, "Statement of Compliance")
      expect(@document2.reload.title).to eq "Statement of Compliance"
      expect(@document1.reload.title).to eq "Statement of Compliance"
    end

    it "should change archive docs to membership of the icc group" do
      @document1.update_attribute(:title, "Statement of Compliance")
      expect(@document2.reload.document_group_id).to eq @icc_group_id
      expect(@document1.reload.document_group_id).to eq @icc_group_id
    end
  end

  context "the icc accreditation document group does not exist already" do
    before do
      @document3 = FactoryGirl.create(:internal_document, :revision=>"1.0")
      @document2 = FactoryGirl.create(:internal_document, :revision=>"1.1", :document_group_id => @document3.document_group_id)
      @document1 = FactoryGirl.create(:internal_document, :revision=>"1.2", :document_group_id => @document2.document_group_id)
    end

    it "should create the accreditation document group" do
      expect(DocumentGroup.count).to eq 1
      @document1.update_attribute(:title, "Statement of Compliance")
      expect(DocumentGroup.count).to eq 1
      expect(DocumentGroup.first.type).to eq "AccreditationDocumentGroup"
    end

    it "should add the document to the newly created document group" do
      @document1.update_attribute(:title, "Statement of Compliance")
      expect(@document1.reload.document_group.type).to eq "AccreditationDocumentGroup"
    end

    it "should change archive docs titles to match the icc title" do
      @document1.update_attribute(:title, "Statement of Compliance")
      expect(@document1.reload.title).to eq "Statement of Compliance"
      expect(@document2.reload.title).to eq "Statement of Compliance"
      expect(@document3.reload.title).to eq "Statement of Compliance"
    end

    it "should change archive docs to membership of the icc group" do
      @document1.update_attribute(:title, "Statement of Compliance")
      expect(@document2.reload.document_group.type).to eq "AccreditationDocumentGroup"
      expect(@document3.reload.document_group.type).to eq "AccreditationDocumentGroup"
    end
  end
end
