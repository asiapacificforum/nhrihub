require "rails_helper"
require 'login_helpers'

feature "Unregistered user tries to log in" do
  scenario "navigation not available before user logs in" do
    visit "/fr"
    expect(page_heading).to eq "S'il vous plaît connecter"
    expect(page).not_to have_selector("#nav")
  end

  scenario "unregistered admin logs in" do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "admin"
    fill_in "Mot de pass", :with => "password"
    click_button "S'identifier..."

    expect(flash_message).to have_text("Votre nom d'utilisateur ou mot de passe est incorrect.")
    expect(page).not_to have_selector("#nav")
    expect(page_heading).to eq "S'il vous plaît connecter"
  end
end

feature "Registered user logs in with valid credentials" do
  include RegisteredUserHelper
  scenario "admin logs in" do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "admin"
    fill_in "Mot de pass", :with => "password"
    click_button "S'identifier..."

    expect(flash_message).to have_text("Connecté avec succès")
    expect(navigation_menu).to include("Admin")
    expect(navigation_menu).to include("Déconnecter")
  end

  scenario "staff member logs in" do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "staff"
    fill_in "Mot de pass", :with => "password"
    click_button "S'identifier..."

    expect(flash_message).to have_text("Connecté avec succès")
    expect(navigation_menu).not_to include("Admin")
    expect(navigation_menu).to include("Déconnecter")
  end
end

feature "Registered user logs in with invalid credentials" do
  include RegisteredUserHelper
  scenario "enters bad password" do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "staff"
    fill_in "Mot de pass", :with => "badpassword"
    click_button "S'identifier..."

    expect(flash_message).to have_text("Votre nom d'utilisateur ou mot de passe est incorrect.")
    expect(page_heading).to eq "S'il vous plaît connecter"
  end

  scenario "enters bad user name" do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "notvaliduser"
    fill_in "Mot de pass", :with => "password"
    click_button "S'identifier..."

    expect(flash_message).to have_text("Votre nom d'utilisateur ou mot de passe est incorrect.")
    expect(page_heading).to eq "S'il vous plaît connecter"
    expect(page).not_to have_selector("#nav")
  end
end
