Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    namespace :dashboard do
      get :index, :to => 'dashboard_controller/index'
    end
  end
end
