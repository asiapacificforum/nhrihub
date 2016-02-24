require 'rails_helper'

describe "next_minor_revision" do
  context "when the group is empty" do
    it "should be 1.0" do
      group = FactoryGirl.create(:document_group)
      expect(group.next_minor_revision).to eq "1.0"
    end
  end

  context "when group is not empty" do
    it "should assign the next minor rev" do
      group = FactoryGirl.create(:document_group)
      first_doc = FactoryGirl.create(:internal_document, :document_group => group, :revision_major => 3, :revision_minor => 100)
      second_doc = FactoryGirl.create(:internal_document, :document_group => group, :revision_major => 2, :revision_minor => 100)
      expect(group.reload.next_minor_revision).to eq "3.101"
    end
  end
end

describe "behaviour when internal_documents are deleted" do
  before do
    @first_doc = FactoryGirl.create(:internal_document, :revision_major => 3, :revision_minor => 3)
    @group = @first_doc.document_group
    @second_doc = FactoryGirl.create(:internal_document, :document_group_id => @group.id, :revision_major => 3, :revision_minor => 2)
  end

  it "should be deleted when last doc is deleted" do
    expect(@group.primary).to eq @first_doc
    expect{@first_doc.destroy}.to change{@group.internal_documents.count}.from(2).to(1)
    expect(@group.primary).to eq @second_doc
    @second_doc.destroy
    expect{DocumentGroup.find(@group.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end
end

describe "default scope" do
  before do
    @id1 = FactoryGirl.create(:internal_document, :null_revision)
    @id2 = FactoryGirl.create(:internal_document, :null_revision, :document_group_id => @id1.document_group_id)
    # second oldest document group
    @id3 = FactoryGirl.create(:internal_document, :null_revision)
    # newest document group
    @id4 = FactoryGirl.create(:internal_document, :null_revision)
    # oldest document group, so last in the list:
    @id5 = FactoryGirl.create(:internal_document, :null_revision, :document_group_id => @id1.document_group_id)
  end

  it "should return internal documents in ascending date order" do
    expect(DocumentGroup.all.map(&:primary).map(&:id)).to eq [@id4.id, @id3.id, @id5.id]
  end
end
