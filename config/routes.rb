Rails.application.routes.draw do
  root "rap_sheets#index"

  resources :rap_sheets, only: [:index]
  resources :rap_sheet_pages, only: [:create, :show]
end
