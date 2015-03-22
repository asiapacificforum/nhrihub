require "rails_helper"
require File.expand_path('../../helpers/login_helpers',__FILE__)
require File.expand_path('../../helpers/navigation_helpers',__FILE__)

feature "User management" do
  include LoggedInFrAdminUserHelper # sets up logged in french admin user
  include NavigationHelpers
  before do
    toggle_navigation_dropdown("Admin")
    select_dropdown_menu_item("Gestion des utilisateurs")
  end

  scenario "add new user, triggering french tranlation of signup email" do
    click_link('Nouvel utilisateur')
    fill_in("Prénom", :with => "Norman")
    fill_in("Nom de famille", :with => "Normal")
    fill_in("Email", :with => "norm@normco.com")
    # ensure that mail was actually sent
    expect{click_button("Conserver")}.to change { ActionMailer::Base.deliveries.count }.by(1)
    email = ActionMailer::Base.deliveries.last
    expect( email.subject ).to eq "S'il vous plaît activer votre compte Office of the Ombudsman M & E Database"
    expect( email.to.first ).to eq "norm@normco.com"
    expect( email.from.first ).to eq "support@www.ombudsman.gov.ws"
    lines = Nokogiri::HTML(email.body.to_s).xpath(".//p").map(&:text)
    # lin[0] is addressee
    expect( lines[0] ).to eq "Norman Normal"
    expect( lines[1] ).to match "Ombudsman M & E Database"
    # activation url is embedded in the email
    url = Nokogiri::HTML(email.body.to_s).xpath(".//p/a").attr('href').value
    expect( url ).to match (/\/fr\/authengine\/activate\/[\d|a|b|c|d|e|f]{40}$/)
    expect( url ).to match (/^http:\/\/www\.ombudsman\.gov\.ws/)
    expect( lines[-1]).to match /Administrateur M & E Database/
    expect( lines[-2]).to match /Vous serez invité à sélectionner un nom de connexion et mot de passe/
  end
end
