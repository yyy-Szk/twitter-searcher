Rails.application.routes.draw do
  get "/login", to: 'sessions#new'
  post 'sessions/create'
  delete 'sessions/destroy'

  root 'home#index'
  # 一時的なもの
  post "search_customers", to: 'home#search_customers'
  get "results/:id", to: 'home#result'
  # TODO: GETでユーザー情報保存するのは良くないと思うのでどうか。
  get '/auth/twitter/callback', to: 'oauth/twitter#new'
    # namespace module: "sessions" do
    # post '/twitter/:provider/callback', to: 'sessions#create'
  # end
end
