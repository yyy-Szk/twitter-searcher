Rails.application.routes.draw do
  root 'home#index'
  # 一時的なもの
  post "search_customers", to: 'home#search_customers'
  get "results/:id", to: 'home#result'
end
