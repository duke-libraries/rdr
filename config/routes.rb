require 'resque_web'

Rails.application.routes.draw do

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  mount Blacklight::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  # Resque web
  authenticate(:user, lambda {|u| u.admin?}) do
    mount ResqueWeb::Engine => "/queues"
  end

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable

  end

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :hyrax, path: :concern do
    namespaced_resources 'datasets' do
      member do
        post :assign_register_doi
      end
    end
  end

  # Export Files
  get 'export_files/:id', to: 'export_files#new', as: 'export_files'
  post 'export_files/:id/unverified_email', to: 'export_files#unverified_email'
  post 'export_files/:id', to: 'export_files#create'

  resources :batch_imports, only: [ :new, :create ]

  get 'id/*local_url_id', to: 'local_urls#show'

  resources :submissions, only: [ :new, :create ]

end
