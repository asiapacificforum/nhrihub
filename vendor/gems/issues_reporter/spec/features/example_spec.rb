require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__

feature "bloo" do
  scenario "blah" do
    expect("bar").to eq "bar"
  end
end
