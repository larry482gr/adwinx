Rails.application.routes.draw do
  scope '(:locale)', locale: /en|gr/ do
    root to: 'home#index'

    devise_for :users, :controllers => { registrations: 'registrations' }

    concern :deleteable do
      delete :bulk_delete, on: :collection
    end

    authenticate do
      resources :contacts do
        get :csv_template, on: :collection
        get :xlsx_template, on: :collection
        get 'export_list/:filename' => 'contacts#export_list', on: :collection
        concerns :deleteable
      end

      resources :contact_groups do
        member do
          patch :remove_contacts
          delete :empty
        end
        concerns :deleteable
      end

      resources :sms_templates do
        concerns :deleteable
      end

      resources :sms_campaigns

      get '/typeahead_contact_groups' => 'contact_groups#typeahead'
      get '/contacts/:id/groups' => 'contacts#belonging_groups'

      # TODO Refactor contacts bulk delete. Add the route through deletable concern and
      # implement it the rails way with form, method delete etc.
      # post '/contacts/bulk_delete' => 'contacts#bulk_delete'
      post '/contacts/bulk_import' => 'contacts#bulk_import'
    end

  end


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
end
