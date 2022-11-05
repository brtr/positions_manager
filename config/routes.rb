Rails.application.routes.draw do
  devise_for :users

  root 'page#user_positions'

  resources :user_positions, only: :index do
    collection do
      get  :refresh
      post :import_csv
    end
  end

  resources :snapshot_infos, only: [:index, :show]

  get '/public_user_positions', to: 'page#user_positions', as: :public_user_positions
  get '/refresh_user_positions', to: 'page#refresh_user_positions', as: :refresh_public_user_positions
  get "/healthcheck", to: "page#health_check"
end
