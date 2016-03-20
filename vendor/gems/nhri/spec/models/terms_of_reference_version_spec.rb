require 'rails_helper'

describe "revision management" do
  it "should set the rev of the first document to 1.0" do
    doc = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create
    expect(doc.revision).to eq("1.0")
  end

  it "should set the second doc rev to 2.0" do
    Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create
    doc = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create
    expect(doc.revision).to eq("2.0")
  end

  it "should set the third doc rev to 3.0" do
    Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create
    Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create
    doc = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create
    expect(doc.revision).to eq("3.0")
  end

  it "should increment the value of the highest rev document" do
    Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create(:revision_major => 1, :revision_minor => 5)
    doc = Nhri::AdvisoryCouncil::TermsOfReferenceVersion.create
    expect(doc.revision).to eq("2.0")
  end
end
