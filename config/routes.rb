Rails.application.routes.draw do
  # Health check endpoints
  get 'health', to: 'health#check'
  get 'health/simple', to: 'health#simple'
  get 'health/detailed', to: 'health#detailed'
  
  # Simple root endpoint for health checks
  get 'up', to: 'health#simple'
  get 'healthz', to: 'health#simple'
  
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
