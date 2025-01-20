Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  
  mount Sidekiq::Web => '/sidekiq'

  namespace :api do
    resources :urls, only: [:create, :index, :show]
  end
  get '/:short_url', to: 'api/redirect#show'
 
end
