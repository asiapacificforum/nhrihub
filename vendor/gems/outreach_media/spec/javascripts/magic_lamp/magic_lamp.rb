MagicLamp.define do
  fixture(:name => 'media_appearance_data') do
    FactoryGirl.create(:media_appearance, :title => "Fantasy land")
    7.times do
      FactoryGirl.create(:media_appearance, :title => Faker::Lorem.sentence(5).gsub(/f/i,"b"))
    end
    MediaAppearance.all
  end

  fixture(:name => 'media_appearance_page') do
    render :partial => 'outreach_media/media/index'
  end
end
