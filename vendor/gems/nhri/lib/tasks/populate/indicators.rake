require Nhri::Engine.root.join('app','models','nhri','heading_generator')

namespace :nhri do
  namespace :human_rights_indicators do
    desc "populates indicators and related tables"
    task :populate => ["headings:populate", "attributes:populate", "indicators:populate"]

    task :depopulate => ["headings:depopulate", "attributes:depopulate", "indicators:depopulate"]

    namespace :headings do
      desc "populates headings"
      task :populate => "nhri:human_rights_indicators:headings:depopulate" do
        6.times do
          FactoryGirl.create(:heading)
        end
      end

      task :depopulate => :environment do
        Nhri::Heading.destroy_all
      end
    end

    namespace :attributes do
      desc "populates human_rights_attributes"
      task :populate => "nhri:human_rights_indicators:attributes:depopulate" do
        Nhri::HeadingGenerator.generate_attributes
      end

      task :depopulate => :environment do
        Nhri::HumanRightsAttribute.destroy_all
      end
    end

    namespace :indicators do
      desc "populates indicators"
      task :populate => "nhri:human_rights_indicators:indicators:depopulate" do
        Nhri::HeadingGenerator.generate
      end #/task

      task :depopulate => :environment do
        Nhri::Indicator.destroy_all
      end #/task
    end
  end
end #/namespace
