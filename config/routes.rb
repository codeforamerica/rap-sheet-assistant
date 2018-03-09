Rails.application.routes.draw do
  root 'static_pages#index'

  resources :users do
    scope module: :users do
      resource :contact_information, only: [:show, :edit, :update]
      resource :case_information, only: [:show, :edit, :update]
      resource :financial_information, only: [:new, :create]
      resource :benefits, only: [:new, :create]
      resource :income_information, only: [:new, :create]
    end
  end

  resources :rap_sheets, only: [:index, :edit, :show, :create] do
    member do
      get :details
      get :ineligible
      get :debug
      put :add_page
      put :remove_page
    end

    resources :documents, only: [:index] do
      collection do
        get :download
      end
    end
  end

  resources :rap_sheet_pages, only: [:create, :destroy]
end
