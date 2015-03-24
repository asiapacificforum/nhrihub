Rails.application.routes.draw do
  #scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
  scope ':locale', locale: /en|fr/ do
    root :to => "authengine/sessions#new"

    namespace :admin do
      resources :users do
        resource :account
        resources :user_roles, :only => [:destroy] do
          collection do
            get 'index' # shows user_roles for a user, from which to add/remove roles
            get 'edit'
            put 'update', :as => 'update'
            post 'create', :as => 'create'
          end
        end

        member do
          put 'enable'
          put 'disable'
          put 'update_self'

          get 'signup'
        end

        collection do
          get 'edit_self'

          post ':activation_code/activate' => 'users#activate'
        end
      end
      post '/send_change_password_email(/:user_id)' => "users#send_change_password_email", :as => :send_change_password_email
      get '/new_password(/:password_reset_code)' => "users#new_password", :as => :new_password
      post '/change_password(/:password_reset_code)' => "users#change_password", :as => :change_password
    end

    namespace :authengine do
      resources :accounts
      resources :actions
      resources :useractions
      resources :action_roles do
        put 'update_all', :on => :collection
      end
      resources :organizations

      resources :sessions
      resources :roles
      resources :users do
        resource :account
        resources :user_roles, :only => [:destroy] do
          collection do
            get 'index' # shows user_roles for a user, from which to add/remove roles
            get 'edit'
            put 'update', :as => 'update'
            post 'create', :as => 'create'
          end
        end

        member do
          put 'enable'
          put 'disable'
          put 'update_self'

          get 'signup'
        end

        collection do
          get 'edit_self'

          post ':activation_code/activate' => 'users#activate'
        end
      end

      get '/activate(/:activation_code)' => "accounts#show", :as => :activate # actually activation_code is always required, but handling it as optional permits its absence to be communicated to the user as a flash message
    end
    get '/login' => "authengine/sessions#new"
    get '/logout' => "authengine/sessions#destroy"

  end
  # Catch all requests without a locale and redirect to the default...
  match '*path', to: redirect("/#{I18n.default_locale}/%{path}"), constraints: lambda { |req| !req.path.starts_with? "/#{I18n.default_locale}/" }, via: [:get, :post]
  match '', to: redirect("/#{I18n.default_locale}"), via: [:get, :post]
end
