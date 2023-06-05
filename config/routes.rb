require "sidekiq/web"
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  devise_for :users

  root 'page#user_positions'
  mount Sidekiq::Web => "/sidekiq"

  resources :user_positions, only: [:index, :edit, :update] do
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
    collection do
      get :positions_graphs
      get :export_roi
    end

    get :export_user_positions, on: :member
  end

  resources :origin_transactions, only: [:index, :edit, :update] do
    collection do
      get :refresh
      get :users
      post :add_key
    end
  end

  resources :combine_transactions, only: :index
  resources :transactions_snapshot_infos, only: [:index, :show]
  resources :synced_transactions, only: :index do
    get :users, on: :collection
  end

  resources :ranking_snapshots, only: [:index, :show] do
    collection do
      get :get_24hr_tickers
      get :list
      get :ranking_graph
    end
  end

  resources :user_spot_balances, only: [:index, :edit, :update] do
    get :refresh, on: :collection
  end

  resources :spot_balance_snapshot_infos, only: [:index, :show]

  resources :user_positions_notes_histories

  get '/public_user_positions', to: 'page#user_positions', as: :public_user_positions
  get '/public_spot_balances', to: 'page#spot_balances', as: :public_spot_balances
  get '/export_user_positions', to: 'page#export_user_positions', as: :export_user_positions
  get '/refresh_user_positions', to: 'page#refresh_user_positions', as: :refresh_public_user_positions
  get "/refresh_24hr_ticker" => "page#refresh_24hr_ticker", as: :refresh_24hr_ticker
  get "/recently_adding_positions" => "page#recently_adding_positions", as: :recently_adding_positions
  get "/refresh_recently_adding_positions" => "page#refresh_recently_adding_positions", as: :refresh_recently_adding_positions
  get "/refresh_public_spot_balances" => "page#refresh_public_spot_balances", as: :refresh_public_spot_balances
  get "/account_balance" => "page#account_balance", as: :account_balance
  get "/price_chart" => "page#price_chart", as: :price_chart
  get "/position_detail" => "page#position_detail", as: :position_detail
  get "/adding_positions_calendar" => "page#adding_positions_calendar", as: :adding_positions_calendar
  post "/set_public_positions_filter" => "page#set_public_positions_filter", as: :set_public_positions_filter

  get "/healthcheck", to: "page#health_check"
end
