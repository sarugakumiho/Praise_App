Rails.application.routes.draw do

  # 会員新規登録・ログイン
  devise_for :members,skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: 'public/sessions'
  }
  
  # 管理者ログイン
  devise_for :admin, skip: [:registrations, :passwords] , controllers: {
    sessions: "admin/sessions"
  }
  
  # ゲストログイン
  devise_scope :member do
    post 'members/guest_sign_in', to: 'public/sessions#guest_sign_in'
  end
  
  # [Public側]
  # homesルーティング
  root 'public/homes#top'
  get 'about', to: 'public/homes#about'
  scope module: :public do
    # membersルーティング
    resources :members, only: [:show, :index] do
      collection do
        get 'my_page'
      end
      member do
        get 'check'
        get 'out'
      end
      resources :posts, only: [:index, :show]
    end
    get '/members/information/edit', to: 'members#edit', as: 'edit_member_information'
    patch '/members/information', to: 'members#update', as: 'update_member_information'
    # relationshipsルーティング
    post '/members/:member_id/relationships', to: 'relationships#create', as: 'relationships_create'
    delete '/members/:member_id/relationships', to: 'relationships#destroy', as: 'relationships_destroy'
    get '/members/:member_id/followings', to: 'relationships#followings', as: 'followings'
    get '/members/:member_id/followers', to: 'relationships#followers', as: 'followers'
    # postsルーティング
    resources :posts, only: [:create, :new, :show, :index, :edit, :update, :destroy] do
      collection do 
        get 'tags'
      end
    end
    get '/posts/tags/search', to: 'posts#search'
    # post_commentsルーティング
    post '/posts/:post_id/post_comments', to: 'post_comments#create', as: 'post_comments'
    delete '/post_comments/:id', to: 'post_comments#destroy', as: 'post_comment'
    # favoritesルーティング
    get '/posts/:post_id/favorites/index', to: 'favorites#index', as: 'favorites_index'
    post '/posts/:post_id/favorites', to: 'favorites#create', as: 'favorites_create'
    delete '/posts/:post_id/favorites/:id', to: 'favorites#destroy', as: 'favorites_destroy'
    # searchesルーティング
    get 'search', to: 'searches#search'
  end
  
  # [Admin側]
  # homesルーティング
  get 'admin', to: 'admin/homes#top'
  namespace :admin do
    # membersルーティング
    resources :members, only: [:index, :show, :edit, :update]
    # postsルーティング
    resources :posts, only: [:show, :index] do
      collection do 
        get 'tags'
      end
    end
    get '/posts/tags/search', to: 'posts#search'
    # post_commentsルーティング
    delete '/posts/:post_id/post_comments/:id', to: 'post_comments#destroy'
    # searchesルーティング
    get 'search', to: 'searches#search'
  end
  
end