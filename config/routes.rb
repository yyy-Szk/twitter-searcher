Rails.application.routes.draw do
  root 'home#index'
  get "search_customers", to: 'home#search_customers'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
