require 'rails_helper'

describe 'to_json' do
  before do
    project = FactoryGirl.create(:project)
    mandate = FactoryGirl.create(:mandate, :key => "human_rights")
    project.mandates << mandate
    @type1 = FactoryGirl.create(:project_type, :mandate_id => mandate.id, :name => "Schools")
    @type2 = FactoryGirl.create(:project_type, :mandate_id => mandate.id, :name => "Police")
    @type3 = FactoryGirl.create(:project_type, :mandate_id => mandate.id, :name => "Farms")
    project.project_types << [@type1,@type2]
    project_json = project.to_json
    @project_ruby = JSON.parse(project_json)
    # {"id"=>1,
    #  "title"=>"voluptas ut illum voluptatum delectus et consequuntur",
    #  "description"=>"Totam sint consequuntur dolore atque non vel quisquam. Tempora velit qui rerum veniam. Aliquam accusamus hic voluptatum sed laboriosam.",
    #  "mandates"=>[{"id"=>1,
    #                "key"=>"some_key",
    #                "name"=>"voluptibas vincit hic",
    #                "project_types"=>[{"id"=>1, "name"=>"Schools"}]}]}
  end

  it "includes mandates array" do
    expect(@project_ruby.keys).to include "id"
    expect(@project_ruby.keys).to include "title"
    expect(@project_ruby.keys).to include "description"
    expect(@project_ruby.keys).to include "areas"
    expect(@project_ruby["areas"]).to be_a Array
  end

  it "includes project types nested in the first mandate" do
    expect(@project_ruby["areas"][0].keys).to include "project_types"
    expect(@project_ruby["areas"][0].keys).to include "name"
  end

  it "includes project_types and not mandate_types inside the mandate" do
    expect(@project_ruby["project_types"][0]["types"].map{|t| t["id"]}).to include @type1.id
    expect(@project_ruby["project_types"][0]["types"].map{|t| t["id"]}).to include @type2.id
    expect(@project_ruby["project_types"][0]["types"].map{|t| t["id"]}).not_to include @type3.id
  end
end
