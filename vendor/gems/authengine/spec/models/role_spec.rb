#require 'spec_helper'
require 'rails_helper'

describe "ancestors method" do
  before(:each) do
    @big_boss = Role.create(:name => "big_boss", :parent_id => nil)
    @boss = Role.create(:name => "boss", :parent_id => @big_boss.id)
    @minion = Role.create(:name => "minion", :parent_id => @boss.id)
  end

  it "minions ancestors should include boss and big boss" do
    expect(@minion.ancestors).to include(@boss)
    expect(@minion.ancestors).to include(@big_boss)
    expect(@minion.ancestors.size).to eq(2)
    expect(@boss.ancestors).to include(@big_boss)
    expect(@boss.ancestors.size).to eq(1)
    expect(@big_boss.ancestors).to be_empty
  end

end

describe "equal_or_lower_than class method" do
  before(:each) do
    @big_boss = Role.create(:name => "big_boss", :parent_id => nil)
    @boss = Role.create(:name => "boss", :parent_id => @big_boss.id)
    @minion = Role.create(:name => "minion", :parent_id => @boss.id)
  end

  it "should return minion and boss when parameter is 'boss'" do
    expect(Role.equal_or_lower_than(@boss)).to include(@minion)
    expect(Role.equal_or_lower_than(@boss)).to include(@boss)
  end

  it "should return minion and boss and big_boss when parameter is an array ['boss','big_boss']" do
    expect(Role.equal_or_lower_than([@boss, @big_boss])).to include(@minion)
    expect(Role.equal_or_lower_than([@boss, @big_boss])).to include(@boss)
    expect(Role.equal_or_lower_than([@boss, @big_boss])).to include(@big_boss)
  end
end
