require 'rails_helper'

describe "Project" do
  context "created with named and other documents" do
    it "saves all associated files when project is created" do
      file1 = ActionDispatch::Http::UploadedFile.new({:tempfile => Tempfile.new('foo'),
                                                     :filename => "uploaded_file.pdf",
                                                     :type => 'application/pdf'})
      project_document1 = ProjectDocument.new(:title => "Anything really", :file => file1)
      file2 = ActionDispatch::Http::UploadedFile.new({:tempfile => Tempfile.new('bar'),
                                                     :filename => "uploaded_file.pdf",
                                                     :type => 'application/pdf'})
      project_document2 = ProjectDocument.new(:title => "Analysis", :file => file2)
      project = GoodGovernance::Project.new(:title => "Project Title",
                                            :project_documents => [project_document1, project_document2])
      expect{ project.save }.to change{ProjectDocument.count}.by(2)
      expect(project.reload.project_documents.count).to eq 2
    end
  end

  context "updated with non-named documents" do
    it "saves added files in addition to existing files" do
      project = FactoryGirl.create(:good_governance_project, :with_documents)
      file = ActionDispatch::Http::UploadedFile.new({:tempfile => Tempfile.new('bar'),
                                                     :filename => "uploaded_file.pdf",
                                                     :type => 'application/pdf'})
      project.update(:project_documents_attributes => [{:title => "A doc title",
                                                        :file => file }])
      expect(project.project_documents.count).to eq 3
    end
  end

  context "updated with named documents" do
    it "saves added files in addition to existing files" do
      project = FactoryGirl.create(:good_governance_project, :with_documents)
      file = ActionDispatch::Http::UploadedFile.new({:tempfile => Tempfile.new('bar'),
                                                     :filename => "uploaded_file.pdf",
                                                     :type => 'application/pdf'})
      project.update(:project_documents_attributes => [{:title => "Project Document",
                                                        :file => file }])
      expect(project.project_documents.count).to eq 3
      expect(project.named_project_documents.count).to eq 1
    end
  end

  context "updated with named documents when there is pre-existing named document" do
    it "saves added files in addition to existing files" do
      project = FactoryGirl.create(:good_governance_project, :with_named_documents)
      file = ActionDispatch::Http::UploadedFile.new({:tempfile => Tempfile.new('bar'),
                                                     :filename => "uploaded_file.pdf",
                                                     :type => 'application/pdf'})
      project.update(:project_documents_attributes => [{:title => "Project Document",
                                                        :file => file }])
      expect(project.project_documents.count).to eq 2
    end
  end
end
