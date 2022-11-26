require "sidekiq/web"
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :users

  root 'page#user_positions'
  mount Sidekiq::Web => "/sidekiq"

  resources :user_positions, only: :index do
    collection do
      get  :refresh
      post :import_csv
    end
  end

  resources :user_synced_positions, only: :index do
    collection do
      get  :refresh
      post :add_key
    end
  end

  resources :snapshot_infos, only: [:index, :show] do
    get :positions_graphs, on: :collection
  end

  get '/public_user_positions', to: 'page#user_positions', as: :public_user_positions
  get '/refresh_user_positions', to: 'page#refresh_user_positions', as: :refresh_public_user_positions
  get "/get_24hr_ticker" => "page#get_24hr_ticker", as: :get_24hr_ticker
  get "/refresh_24hr_ticker" => "page#refresh_24hr_ticker", as: :refresh_24hr_ticker

  get "/healthcheck", to: "page#health_check"
end
