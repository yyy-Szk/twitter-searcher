Rails.application.routes.draw do
  resources :twitter_search_processes, only: %i[new show create update]
  get "twitter_search_processes/:id/json_data", to: "twitter_search_processes#json_data"

  get "/login", to: 'sessions#new'
  delete "/logout", to: 'sessions#destroy'
  post 'sessions/create'
  delete 'sessions/destroy'

  post '/process_stop/:id', to: 'home#process_stop'
  root 'home#index'
  # 一時的なもの
  post "search_customers", to: 'home#search_customers'
  # TODO: GETでユーザー情報保存するのは良くないと思うのでどうか。
  get '/auth/twitter/callback', to: 'oauth/twitter#new'
end
