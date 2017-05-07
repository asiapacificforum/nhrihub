Rails.application.routes.draw do
  scope ':locale', locale: /en|fr/ do
    root :to => "authengine/sessions#new"

    namespace :admin do
      resources :organizations
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

          post ':activation_code/activate' => 'users#activate', :as => :register
        end
      end
      post '/send_change_password_email(/:user_id)' => "users#send_change_password_email", :as => :send_change_password_email
      post '/send_forgot_password_email' => "users#send_forgot_password_email", :as => :send_forgot_password_email
      post '/resend_registration_email(/:user_id)' => "users#resend_registration_email", :as => :resend_registration_email
      post '/send_lost_token_email(/:user_id)' => "users#send_lost_token_email", :as => :send_lost_token_email
      get '/new_password(/:password_reset_code)' => "users#new_password", :as => :new_password
      post '/change_password(/:password_reset_code)' => "users#change_password", :as => :change_password
      get '/register_replacement_token_request/(/:replacement_token_registration_code)' => "users#register_new_token_request", :as => "register_new_token_request"
      post '/register_replacement_token_response/(/:replacement_token_registration_code)' => "users#register_new_token_response", :as => "register_new_token_response"
    end

    namespace :authengine do
      resources :accounts
      resources :actions
      resources :useractions
      resources :action_roles do
        get 'index', :on => :collection
        put 'update', :on => :collection
      end

      resources :sessions
      resources :roles
      resources :users do
        resource :account

        member do
          put 'enable'
          put 'disable'
          put 'update_self'

          get 'signup'
        end

        collection do
          get 'edit_self'
        end
      end

      get '/fido(/:password_reset_code)' => 'fido#challenge_request', :as => 'challenge_request'

      get '/activate(/:activation_code)' => "accounts#show", :as => :activate # actually activation_code is always required, but handling it as optional permits its absence to be communicated to the user as a flash message
    end
    get '/login' => "authengine/sessions#new"
    get '/logout' => "authengine/sessions#destroy"

  end
end
