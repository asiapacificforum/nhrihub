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


  scope "/:locale" do
  # this route is specified as it's used in authengine as the place
  # where logged-in users first land
    get 'home', :to => 'home#index'
    get 'placeholder', :to => 'placeholder#index'
    resources :internal_documents
    resources :projects do
      resources :project_performance_indicators, :only => :destroy
    end
    namespace :project_document do
      resources :filetypes, :param => :ext, :only => [:create, :destroy]
      resource :filesize, :only => :update
    end
    resources :project_documents, :only => [:destroy, :show]
    resources :complaint_documents, :only => [:destroy, :show]
    resource :project_admin, :only => :show, :to => 'project_admin#show'
    resource :complaint_admin, :only => :show, :to => 'complaint_admin#show'
    resources :complaints
    resources :complaints do
      resources :reminders, :controller => "complaint/reminders"
      resources :notes, :controller => "complaint/notes"
    end
    resources :good_governance_complaint_bases, :only => [:create, :destroy], :controller => 'good_governance/complaint_bases'
    resources :siu_complaint_bases, :only => [:create, :destroy], :controller => 'siu/complaint_bases'
    resources :complaint_categories, :only => [:create, :destroy]
    namespace :good_governance do
      resources :project_types, :only => [:create, :destroy]
    end
    namespace :siu do
      resources :project_types, :only => [:create, :destroy]
    end
    namespace :human_rights do
      resources :project_types, :only => [:create, :destroy]
    end


  end
end
