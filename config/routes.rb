Rails.application.routes.draw do

  root 'projects#index'

  get "/auth/:provider/callback" => "sessions#create"
  get '/session' => "sessions#create"

  get 'take_action' => "logged_out#take_action"

  # resources :accounts, only: %i[new create edit update]
  resource :session, only: %i[create destroy]
  get '/log_out', to: "sessions#destroy"
  get '/logout', to: "sessions#destroy"

  resources :projects

  namespace :admin do
    get '/' => 'admin#index'
    resources :accounts
    resources :roles
    get '/metrics' => 'metrics#index'
  end
end
