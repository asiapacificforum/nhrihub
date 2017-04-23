require Nhri::Engine.root.join('app','models','nhri','heading_generator')

namespace :nhri do
  desc "populates indicators and related tables"
  task :human_rights_indicators => [:populate_headings, :populate_attributes, :populate_indicators] do
    puts "populate human rights indicators"
  end


  desc "populates headings"
  task :populate_headings => :environment do
    puts "populate headings"
    Nhri::Heading.destroy_all
    6.times do
      FactoryGirl.create(:heading)
    end
  end

  desc "populates human_rights_attributes"
  task :populate_attributes => :environment do
    puts "populate attributes"
    Nhri::HumanRightsAttribute.destroy_all
    Nhri::HeadingGenerator.generate_attributes
  end

  desc "populates indicators"
  task :populate_indicators => :environment do
    puts "populate indicators"
    Nhri::Indicator.destroy_all
    Nhri::HeadingGenerator.generate
  end #/task
end #/namespace
