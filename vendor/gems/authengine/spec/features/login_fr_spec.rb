require "rails_helper"
require 'login_helpers'

feature "Unregistered user tries to log in", :js => true do
  scenario "navigation not available before user logs in", :driver => :chrome do
    visit "/fr"
    expect(page_heading).to eq "S'il vous plaît connecter"
    expect(page).not_to have_selector(".nav")
  end

  scenario "unregistered admin logs in", :driver => :chrome do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "admin"
    fill_in "Mot de pass", :with => "password"
    page.find('#sign_up').click

    expect(flash_message).to have_text("Votre nom d'utilisateur ou mot de passe est incorrect.")
    expect(page).not_to have_selector(".nav")
    expect(page_heading).to eq "S'il vous plaît connecter"
  end
end

feature "Registered user logs in with valid credentials", :js => true do
  include RegisteredUserHelper
  scenario "admin logs in", :driver => :chrome do
    visit "/fr"
    configure_keystore

    fill_in "Nom d'usilateur", :with => "admin"
    fill_in "Mot de pass", :with => "password"
    login_button.click

    expect(flash_message).to have_text("Connecté avec succès")
    expect(navigation_menu).to include("Admin")
    expect(navigation_menu).to include("Déconnecter")
  end

  scenario "staff member logs in", :driver => :chrome do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "staff"
    fill_in "Mot de pass", :with => "password"
    login_button.click

    expect(flash_message).to have_text("Connecté avec succès")
    expect(navigation_menu).not_to include("Admin")
    expect(navigation_menu).to include("Déconnecter")
  end
end

feature "Registered user logs in with invalid credentials", :js => true do
  include RegisteredUserHelper
  scenario "enters bad password", :driver => :chrome do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "staff"
    fill_in "Mot de pass", :with => "badpassword"
    login_button.click

    expect(flash_message).to have_text("Votre nom d'utilisateur ou mot de passe est incorrect.")
    expect(page_heading).to eq "S'il vous plaît connecter"
  end

  scenario "enters bad user name", :driver => :chrome do
    visit "/fr"

    fill_in "Nom d'usilateur", :with => "notvaliduser"
    fill_in "Mot de pass", :with => "password"
    login_button.click

    expect(flash_message).to have_text("Votre nom d'utilisateur ou mot de passe est incorrect.")
    expect(page_heading).to eq "S'il vous plaît connecter"
    expect(page).not_to have_selector(".nav")
  end
end
