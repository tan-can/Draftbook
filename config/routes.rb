Rails.application.routes.draw do
  root "dashboard#index"

  resource :registration, only: [ :new, :create ]
  resource :session
  resources :passwords, param: :token

  resources :tasks do
    member do
      patch :toggle
    end
  end

  resources :goals do
    member do
      patch :toggle
    end
  end

  resources :habits

  # Admin Namespace (allows /admin and /admin/users)
  namespace :admin do
    get "/", to: "users#index"
    resources :users, only: [ :index, :destroy ]
  end

  # API Namespace
  namespace :api do
    namespace :v1 do
      resources :tasks, only: [ :index, :create ]
    end
  end
end
