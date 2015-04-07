Rails.application.routes.draw do
  scope ':locale' do
    namespace :nhri do
      resources :hr_education
      resources :advisory_council
      resources :nhr_indicators
      resources :hr_protection
      resources :icc
    end
  end
end
