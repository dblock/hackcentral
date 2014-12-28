class SubdomainPresent
  def self.matches?(request)
    request.subdomain.present? && request.subdomain != 'www'
  end
end

class SubdomainBlank
  def self.matches?(request)
    request.subdomain.blank? or request.subdomain == 'www'
  end
end

Rails.application.routes.draw do

  # Subdomain Routing
  constraints(SubdomainPresent) do
    get '/' => 'hackathons#show', as: :hackathon #, :constraints => { :subdomain => /.+/ } #get '/' => 'hackathons#index'#, via: :get#, :constraints => { :subdomain => /.+/ }, via: :get
    get '/participants' => 'hackathon_extras#participants', as: :hackathon_participants
    get '/rules' => 'hackathon_extras#rules', as: :hackathon_rules
  end

  # Normal Routing
  constraints(SubdomainBlank) do
    # Root
    root to: 'pages#home'

    # Static Pages
    get 'pages/about' => "pages#about"
    get 'pages/contact' => "pages#contact"

    # Scaffolds
    resources :profiles
    resources :applications
    resources :submissions, only: :show do
      resource :like, module: :submissions
    end
    resources :hackathons, except: [:edit, :show] do
      resources :submissions, except: [:show, :tag]
    end

    # Submission Tags
    get 'tags/:tag', to: 'submissions#tag', as: :tag

    # Devise
    devise_for :users, :path => '', :path_names => {:sign_in => 'login', :sign_out => 'logout', :sign_up => 'register'}
    resources :users, only: [:show]

    # API
    use_doorkeeper do
      controllers :applications => 'oauth/applications'
    end

    namespace :api, defaults: {format: 'json'} do
      scope module: :v1 do
        get '/user' => "users#show"
        get 'tags/:tag', to: 'submissions#tag', as: :tag
        resources :submissions, only: [:show]
        resources :profiles
        resources :applications
        resources :hackathons do
          resources :submissions, except: [:show, :tag], controller: :submissions
        end
      end
    end

    # Root Admin
      get "/admin" => "admin/dashboards#index"
    # MLH Admin
      get "/admin/mlh" => "admin/dashboards#mlh_root"
      post "/admin/mlh/sanction/:hackathon_id" => "admin/dashboards#mlh_sanction"
      post "/admin/mlh/unsanction/:hackathon_id" => "admin/dashboards#mlh_unsanction"
    # Organizer Admin
      get "/admin/hackathons/:hackathon_id/" => "admin/hackathons#index", as: :admin_hackathon

      scope '/admin' do
        resources :hackathons, only: [:edit] do
          resources :organizers, except: [:show, :edit, :update]
        end
      end

      get "/admin/hackathons/:hackathon_id/applications" => "admin/hackathons#application_index", as: :admin_applications_hackathon
      get "/admin/hackathons/:hackathon_id/applications/:application_id/" => "admin/hackathons#application_show"
      post "/admin/hackathons/:hackathon_id/applications/:application_id/accept" => "admin/hackathons#application_accept"
      post "/admin/hackathons/:hackathon_id/applications/:application_id/unaccept" => "admin/hackathons#application_unaccept"

      get "/admin/hackathons/:hackathon_id/tickets" => "admin/hackathons#checkin_index", as: :admin_tickets_hackathon
      post "/admin/hackathons/:hackathon_id/:application_id/checkin" => "admin/hackathons#checkin"
      post "/admin/hackathons/:hackathon_id/:application_id/uncheckin" => "admin/hackathons#uncheckin"
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
