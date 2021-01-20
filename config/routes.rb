require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  if ENV['WHITELABEL']
    root 'projects#index'
  else
    root 'pages#featured'
  end

  resources :tokens, only: [:index, :new, :create, :show, :edit, :update] do
    collection do
      post :fetch_contract_details
    end
  end

  get '/styleguide' => "pages#styleguide"
  get '/unsubscription' => "unsubscription#new", as: :unsubscription

  resource :account, only: [:update]
  resources :wallets
  resources :algorand_opt_ins, only: %i[index create]
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
    resources :interests, only: [:create, :destroy], defaults: { format: :json }

    namespace :dashboard do
      resources :transfers, only: [:index, :show, :create]
      resources :accounts, only: [:index, :update]
      resources :accesses, only: [:index] do
        collection do
          post :regenerate_api_key
          post :add_admin
          delete :remove_admin
        end
      end
      resources :reg_groups, only: [:create, :update, :destroy]

      get 'transfer_categories', to: 'transfer_types#index', as: :transter_categories

      resources :transfer_types, only: [:create, :update, :destroy]
      resources :transfer_rules, only: [:create, :destroy, :index] do
        collection do
          post :pause
          post :unpause
          post :refresh_from_blockchain
        end
      end
    end

    member do
      get :awards
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

  namespace :auth, defaults: { format: :json } do
    resources :eth, only: [:new, :create]

    post 'ore_id/new'
    delete 'ore_id/destroy'
    get 'ore_id/receive'
  end

  namespace :sign, defaults: { format: :json } do
    post 'ore_id/new'
    get 'ore_id/receive'
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :accounts, only: [:show, :update, :create] do
        resources :interests, only: [:index, :create, :destroy]
        resources :verifications, only: [:index, :create]
        resources :wallets, only: [:index, :create, :show, :destroy] do
          member do
            post :password_reset
          end
        end
        resources :transfers, only: [:index], controller: :account_transfers
        get :token_balances
      end

      resources :projects, only: [:show, :index] do
        resources :blockchain_transactions, only: [:create, :update, :destroy]
        resources :transfers, only: [:index, :show, :create, :destroy]
        resources :account_token_records, only: [:index, :show, :create, :destroy]
        resources :transfer_rules, only: [:index, :show, :create, :destroy]
        resources :reg_groups, only: [:index, :show, :create, :destroy]
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
