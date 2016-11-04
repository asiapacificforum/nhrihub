require_relative './headings_seed_data'

MagicLamp.define do
  fixture(:name => "headings_data") do
    HeadingsSeedData.initialize(:headings)
    Nhri::Heading.all.to_json(:only =>[:title, :id],
                              :include => {
                                :human_rights_attributes=>{
                                  :only => [:heading_id, :id, :description]
                                }
                              })
  end

  fixture(:name => 'headings_page', :controller => Nhri::HeadingsController) do
    render :index, :layout => 'application'
  end
end
