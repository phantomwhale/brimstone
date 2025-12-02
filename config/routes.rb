Rails.application.routes.draw do
  resources :heroes do
    resources :adjustments, only: [:create, :update, :destroy] do
      member do
        patch :toggle
      end
    end
    
    resources :items, only: [:create, :edit, :update, :destroy] do
      member do
        patch :equip
        patch :unequip
      end
    end
    
    resources :sidebag_tokens, only: [:create, :destroy]
    resources :injuries, only: [:create, :destroy]
    resources :madnesses, only: [:create, :destroy]
    resources :mutations, only: [:create, :destroy]
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Mount Mission Control for job monitoring (protect in production)
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Defines the root path route ("/")
  root "heroes#index"
end
