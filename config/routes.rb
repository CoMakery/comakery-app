Rails.application.routes.draw do

  root 'projects#index'

  get "/auth/:provider/callback" => "sessions#create"
  get '/session' => "sessions#create"

  get '/home', to: "logged_out#show", as: :logged_out

  resource :session, only: %i[create destroy] do
    get "oauth_failure"
  end
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
