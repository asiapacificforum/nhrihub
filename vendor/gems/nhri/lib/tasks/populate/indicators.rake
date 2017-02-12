require Nhri::Engine.root.join('app','models','nhri','heading_generator')

namespace :nhri do
  desc "populates indicators and related tables"
  task :populate_ind_etc => [:populate_head, :populate_off, :populate_ind]

  desc "populates headings"
  task :populate_head => :environment do
    Nhri::Heading.destroy_all
    6.times do
      FactoryGirl.create(:heading)
    end
  end

  desc "populates human_rights_attributes"
  task :populate_off => :environment do
    Nhri::HumanRightsAttribute.destroy_all
    Nhri::HeadingGenerator.generate_attributes
  end

  desc "populates indicators"
  task :populate_ind => :environment do
    Nhri::Indicator.destroy_all
    Nhri::HeadingGenerator.generate
  end #/task
end #/namespace
