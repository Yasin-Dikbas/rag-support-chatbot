Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    post "signup", to: "registrations#create"
    post "login", to: "sessions#create"
    get "me", to: "sessions#show"

    resources :chatbots, only: [ :index, :create, :show, :update, :destroy ] do
      post :regenerate_widget_key, on: :member

      resources :documents, only: [ :index, :create, :destroy ] do
        post :retry, on: :member
      end

      resources :conversations, only: [ :index, :show ]
    end

    namespace :widget do
      get ":widget_key", to: "chatbots#show"
      post ":widget_key/messages", to: "messages#create"
    end
  end
end
