Rails.application.routes.draw do
  get "home/index"
  # API Routes
  namespace :api do
    namespace :v1 do
      resources :products
      resources :contacts
      resources :users
      resources :purchase_orders
      resources :sales_orders
      resources :inventories
      resources :accounts_payable
      resources :accounts_receivable
      
      # Rotas customizadas
      post 'auth/login', to: 'auth#login'
      post 'auth/logout', to: 'auth#logout'
      get 'auth/me', to: 'auth#me'
    end
  end
  
  # Rotas da aplicação web (se houver)
  root "home#index"
end