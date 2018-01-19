Rails.application.routes.draw do
  root "rap_sheets#index"

  resources :rap_sheets, only: [:index, :edit, :show]
  resources :rap_sheet_pages, only: [:create]
end
