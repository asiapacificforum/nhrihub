MagicLamp.define do
  fixture(:name => 'media_appearance_data') do
    FactoryGirl.create(:media_appearance, :title => "Fantasy land", :created_at => Date.new(2015,1,1), :description => {:areas => [{:name => "Human Rights", :subareas => [] }]})
    FactoryGirl.create(:media_appearance, :title => "May the force be with you", :created_at => Date.new(2014,1,1), :description => {:areas => [{:name => "Human Rights", :subareas => [] },{:name => "Human Wrongs", :subareas => [] }]})
    6.times do
      FactoryGirl.create(:media_appearance, :title => Faker::Lorem.sentence(5).gsub(/f/i,"b"), :created_at => Date.new(2014,1,1))
    end
    MediaAppearance.all
  end

  fixture(:name => 'media_appearance_page') do
    render :partial => 'outreach_media/media/index'
  end
end
