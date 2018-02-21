Rails.application.routes.draw do
  root 'static_pages#index'

  resources :rap_sheets, only: [:index, :edit, :show, :create] do
    member do
      get :details
      get :debug
      put :add_page
      put :remove_page
    end
  end

  resources :rap_sheet_pages, only: [:create, :destroy]
end
