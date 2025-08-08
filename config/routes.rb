Rails.application.routes.draw do
  # Health check endpoint
  get 'health', to: 'health#check'
  
  # Main search page
  root 'search#index'
  
  # Search pages
  get 'search', to: 'search#index'
  get 'analytics', to: 'search#analytics'
  
  # Article pages
  resources :articles, only: [:show]
  
  # API endpoints for search events
  namespace :api do
    resources :search_events, only: [:create]
    get 'search', to: 'search#index'
  end
end
