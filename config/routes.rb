Rails.application.routes.draw do
  root "rap_sheets#index"

  resources :rap_sheets, only: [:index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
