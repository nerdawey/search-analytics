Rails.application.routes.draw do
  get 'health', to: 'health#check'
  get 'health/simple', to: 'health#simple'
  get 'health/detailed', to: 'health#detailed'
  
  get 'up', to: 'health#simple'
  get 'healthz', to: 'health#simple'
  
  root 'search#index'
  
  get 'search', to: 'search#index'
  get 'analytics', to: 'search#analytics'
  
  resources :articles, only: [:show]
  
  namespace :api do
    resources :search_events, only: [:create]
    get 'search', to: 'search#index'
  end
end
