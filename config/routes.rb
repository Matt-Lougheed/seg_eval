Rails.application.routes.draw do
    get 'algorithms/new'

    get 'datasets/new'
    get 'sessions/new'
    root 'main_pages#home'
    get 'help' => 'main_pages#help'
    get 'about' => 'main_pages#about'
    get 'contact' => 'main_pages#contact'
    get 'signup' => 'users#new'
    get 'login' => 'sessions#new'
    post 'login' => 'sessions#create'
    delete 'logout' => 'sessions#destroy'

    get 'download' => 'datasets#download'
    get 'datasets/info' => 'datasets#info'
    
    resources :users
    resources :datasets
    resources :results
    resources :algorithms do
        member do
            get :download
        end
    end
end
