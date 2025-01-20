Rails.application.routes.draw do
  devise_for :users
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  
  mount Sidekiq::Web => '/sidekiq'
  post 'auth/login', to: 'auth/sessions#create'
  post 'auth/signup', to: 'auth/sessions#signup'

  namespace :api do
    resources :urls, only: [:create, :index, :show]
  end
  get '/:short_url', to: 'api/redirect#show'
 
end
