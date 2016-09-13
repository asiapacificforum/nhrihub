require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__

feature "bloo" do
  xscenario "blah" do
    expect("foo").to eq "bar"
  end
end
