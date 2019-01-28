Rails.application.routes.draw do
  root 'rap_sheet_pdf#new'

  resources :users do
    scope module: :users do
      resource :contact_information, only: [:show, :edit, :update]
      resource :financial_information, only: [:new, :create]
      resource :benefits, only: [:new, :create]
      resource :income_information, only: [:new, :create]
      resource :representations, only: [:new] do
        collection do
          post :yes
          post :no
        end
      end
    end
    resources :attorneys, only: [:new, :create]
  end


  resources :rap_sheets, only: [:index, :edit, :show, :create] do
    member do
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

  resources :rap_sheet_pdf, only: [:new, :create]

  resources :rap_sheet_pages, only: [:create, :destroy]
  get 'healthcheck', to: proc { [200, {}, ['']] }

  mount Cfa::Styleguide::Engine => "/cfa"

  # keep last
  match '*path', via: [:all], to: 'application#not_found'
end
