Rails.application.routes.draw do

  root 'logged_out#index'

  get "/auth/:provider/callback" => "sessions#create"

  get 'take_action' => "logged_out#take_action"

  # resources :accounts, only: %i[new create edit update]
  resource :session, only: %i[create destroy]
  resources :projects

  get 'my_account' => 'logged_in#landing'

  namespace :admin do
    get '/' => 'admin#index'
    resources :accounts
    resources :roles
    get '/metrics' => 'metrics#index'
  end
end
