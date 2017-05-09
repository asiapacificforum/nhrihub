Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # see https://github.com/crismali/magic_lamp
  mount MagicLamp::Genie, at: "/magic_lamp" if defined?(MagicLamp)

  mount LetsencryptPlugin::Engine, at: '/'
  mount GetBack::Engine, at: '/'

  scope "/:locale" do
  # this route is specified as it's used in authengine as the place
  # where logged-in users first land
    get 'home', :to => 'home#index'
    resources :csp_reports, :only => [:index, :create]
    get 'csp_reports/clear_all', :to => 'csp_reports#clear_all', :via => :get
  end
  # Catch all requests without a locale and redirect to the default...
  # see https://dhampik.com/blog/rails-routes-tricks-with-locales for explanation
  match '*path', to: redirect("/#{I18n.default_locale}/%{path}"), constraints: lambda { |req| !req.path.starts_with? "/#{I18n.default_locale}" }, via: [:get, :post]
  match '', to: redirect("/#{I18n.default_locale}"), via: [:get, :post]
end
