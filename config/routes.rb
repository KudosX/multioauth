Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :users, only: [:new, :create, :edit, :update]
  resources :sessions, only: [:new, :create]
  resources :social_accounts, only: [:destroy] do
    collection do
      get 'additional_info'
      post 'finalize'
    end
  end
  delete '/logout', to: 'sessions#destroy', as: :logout

  get '/auth/:provider/callback', to: 'social_accounts#create'
 # get '/auth/twitter/callback', to: 'social_accounts#create'
  root 'static_pages#index'

  get 'static_pages/about'

  get 'static_pages/faq'

  get 'static_pages/contact'
end