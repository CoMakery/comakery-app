require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'pages#featured'

  resources :tokens, only: [:index, :new, :create, :show, :edit, :update] do
    collection do
      post :fetch_contract_details
    end
  end

  get '/styleguide' => "pages#styleguide"
  get '/unsubscription' => "unsubscription#new", as: :unsubscription

  resource :account, only: [:update]
  resources :accounts, only: [:new, :create, :show] do
    collection do
      get :download_data
      get :build_profile
      patch :update_profile
    end
  end

  resources :password_resets, only: [:new, :create, :edit, :update]

  get '/account' => "accounts#show", as: :show_account
  get "accounts/confirm/:token" => "accounts#confirm", as: :confirm_email
  get "accounts/confirm-authentication/:token" => "accounts#confirm_authentication", as: :confirm_authentication
  get "/auth/slack/callback" => "sessions#create"
  post "/auth/slack" => "sessions#create", as: :login

  get "/auth/discord/callback" => "sessions#create"
  post "/auth/discord" => "sessions#create", as: :login_discord

  get '/logout', to: "sessions#destroy"

  post '/add-interest' => "pages#add_interest", as: :add_interest

  get '/joinus' => "pages#join_us"
  get '/user-agreement' => "pages#user_agreement"
  get '/e-sign-disclosure' => "pages#e_sign_disclosure"
  get '/privacy-policy' => "pages#privacy_policy"
  get '/prohibited-use' => "pages#prohibited_use"
  get '/contribution_licenses/:type' => "pages#contribution_licenses", as: :contribution_licenses

  resource :session, only: %i[new create destroy] do
    get "oauth_failure"
    collection do
      post :sign_in
    end
  end
  get '/session' => "sessions#create"

  get '/tasks' => "awards#index", as: :my_tasks

  post '/slack/command' => "slack#command"

  get '/projects/mine' => "projects#landing", as: :my_project
  
  resources :projects do
    resources :award_types, path: 'batches', except: [:show] do
      resources :awards, path: 'tasks', except: [:index] do
        post :recipient_address
        post :send_award
        post :update_transaction_address
        get :clone
        get :award
        get :assignment
        post :assign
        post :start
        get :start
        post :submit
        post :accept
        post :reject
      end
    end
    resources :contributors, only: [:index]

    namespace :dashboard do
      resources :transfers, only: [:index, :create]
      resources :accounts, only: [:index, :update]
      resources :reg_groups, only: [:create, :destroy]
      resources :transfer_rules, only: [:create, :destroy, :index] do
        collection do
          post :pause
          post :unpause
        end
      end
    end
    
    member do
      get :awards
      get :admins
      post :add_admin
      delete :remove_admin
    end
    
    collection do
      get :landing
      patch :update_status
    end
  end

  get '/p/:long_id' => "projects#unlisted", as: :unlisted_project
  get "awards/confirm/:token" => "awards#confirm", as: :confirm_award

  resources :teams, only: [:index] do
    member do
      get :channels
    end
  end

  resources :channels, only: [] do
    member do
      get :users
    end
  end

  resources :missions do
    collection do
      post :rearrange
    end
  end

  namespace :api, defaults: { format: :json } do
    resources :accounts, only: [:create] do
      collection do
        get :find_by_public_address
        post :auth
      end
    end

    namespace :v1 do
      resources :accounts, only: [:show, :update, :create] do
        resources :interests, only: [:index, :create, :destroy]
        resources :verifications, only: [:index, :create]
        get :token_balances
      end

      resources :projects, only: [:show, :index] do
        resources :transfers, only: [:index, :show, :create, :destroy]
      end
    end
  end

  unless Rails.env.development? || Rails.env.test?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username.present? && password.present? &&
        username == ENV["SIDEKIQ_USERNAME"] && password == ENV["SIDEKIQ_PASSWORD"]
    end
  end
  mount Sidekiq::Web, at: "/admin/sidekiq"
end
