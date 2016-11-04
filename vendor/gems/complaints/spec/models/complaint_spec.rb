require 'rails_helper'

describe "complaint" do
  context "create" do
    before do
      @complaint = Complaint.create({:complaint_statuses_attributes => [{:name => nil}]})
    end
    it "should create a status_change and link to 'Under Evaluation' complaint status" do
      expect(@complaint.status_changes.length).to eq 1
      expect(@complaint.complaint_statuses.length).to eq 1
      expect(@complaint.complaint_statuses.first.name).to eq "Under Evaluation"
      expect(@complaint.current_status_humanized).to eq "Under Evaluation"
    end
  end

  context "update status" do
    before do
      @complaint = Complaint.create({:complaint_statuses_attributes => [{:name => nil}]})
      @complaint.update({:complaint_statuses_attributes => [{:name => "Active"}]})
    end

    it "should create a status change object and link to the Active complaint status" do
      expect(@complaint.status_changes.length).to eq 2
      expect(@complaint.complaint_statuses.map(&:name)).to eq ["Under Evaluation", "Active"]
    end
  end

  context "update Complaint with no status change" do
    before do
      @complaint = Complaint.create({:complaint_statuses_attributes => [{:name => nil}]})
      @complaint.update({:complaint_statuses_attributes => [{:name => nil }]})
    end

    it "should create a status change object and link to the Active complaint status" do
      expect(@complaint.status_changes.length).to eq 1
      expect(@complaint.complaint_statuses.map(&:name)).to eq ["Under Evaluation"]
    end
  end
end
