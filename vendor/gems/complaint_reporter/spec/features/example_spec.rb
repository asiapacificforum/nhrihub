require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__

feature "bloo" do
  scenario "blah" do
    expect(1).to eq 1
  end
end
