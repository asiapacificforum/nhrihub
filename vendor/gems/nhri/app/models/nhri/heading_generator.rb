# utility class for populating a heading table for rake task and also test fixture
class Nhri::HeadingGenerator
  def self.generate(option=:random)
    @option = option
    Nhri::Heading.all.each do |heading|
      ["Structural", "Process", "Outcomes"].each do |nature|
        populate_nature(nature,heading)
        heading.human_rights_attributes.pluck(:id).each do |o_id|
          populate_attribute(nature,heading,o_id)
        end #o_id loop
      end #nature loop
    end #/Nhri::Heading
  end

  def self.fixed?
    @option == :fixed
  end

  def self.random?
    @option == :random
  end

  def self.generate_attributes
    Nhri::Heading.pluck(:id).each do |h_id|
      5.times do
        FactoryGirl.create(:human_rights_attribute, :heading_id => h_id)
      end
    end
  end

  def self.populate_attribute(nature,heading,o_id)
    3.times do
      create_indicator(nature,heading,o_id)
    end #/3.times
  end

  def self.count(n)
    fixed? ? n : rand(n)
  end

  def self.populate_nature(nature,heading)
    n = count(3) + 1
    n.times do
      create_indicator(nature,heading,nil)
    end #/rand(4) loop
  end

  def self.create_indicator(nature,heading,o_id)
    type = ["text", "numeric", "file"].sample
    case type
    when "text"
      create_indicator_with_text_monitor(nature,heading,o_id)
    when "numeric"
      create_indicator_with_numeric_monitor(nature,heading,o_id)
    else
      create_indicator_with_file_monitor(nature,heading,o_id)
    end #/case
  end

  def self.text_monitors
    count(3).times.collect{|i| FactoryGirl.build(:text_monitor)}
  end

  def self.numeric_monitors
    count(3).times.collect{|i| FactoryGirl.build(:numeric_monitor)}
  end

  def self.notes
    count(3).times.collect{|i| FactoryGirl.build(:note)}
  end

  def self.reminders
    count(3).times.collect{|i| FactoryGirl.build(:reminder)}
  end

  def self.title
    fixed? ? "foo" : Faker::Lorem.sentence
  end

  def self.create_indicator_with_text_monitor(nature,heading,o_id)
    FactoryGirl.create(:indicator,
                       :title => title,
                       :nature => nature,
                       :human_rights_attribute_id => o_id,
                       :heading_id => heading.id,
                       :notes => notes,
                       :reminders => reminders,
                       :text_monitors => text_monitors)
  end


  def self.create_indicator_with_numeric_monitor(nature,heading,o_id)
    FactoryGirl.create(:indicator,
                       :title => title,
                       :nature => nature,
                       :human_rights_attribute_id => o_id,
                       :heading_id => heading.id,
                       :numeric_monitor_explanation => Faker::Lorem.words(7).join(' '),
                       :notes => notes,
                       :reminders => reminders,
                       :numeric_monitors => numeric_monitors)
  end

  def self.create_indicator_with_file_monitor(nature,heading,o_id)
    monitor = FactoryGirl.build(:file_monitor)
    FactoryGirl.create(:indicator,
                       :title => title,
                       :nature => nature,
                       :human_rights_attribute_id => o_id,
                       :heading_id => heading.id,
                       :notes => notes,
                       :reminders => reminders,
                       :file_monitor => monitor)
  end
end
