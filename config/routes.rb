Rails.application.routes.draw do
  root 'static_pages#index'

  resources :rap_sheets, only: [:index, :edit, :show, :create] do
    member do
      get :completed
    end
  end

  resources :rap_sheet_pages, only: [:create]
end
