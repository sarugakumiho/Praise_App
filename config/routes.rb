Rails.application.routes.draw do

  devise_for :members,skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: 'public/sessions'
  }
  
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
    end
    get '/members/information/edit' => 'members#edit'
    patch '/members/information' => 'members#update'
    # relationshipsルーティング
    post '/members/:member_id/relationships' => 'relationships#create'
    delete '/members/:member_id/relationships' => 'relationships#destroy'
    get '/members/:member_id/followers' => 'relationships#followers'
    get '/members/:member_id/followeds' => 'relationships#followeds'
    # postsルーティング
    resources :posts, only: [:create, :new, :show, :index, :edit, :update, :destroy] do
      collection do 
        get 'tags'
      end
    end
    get '/posts/tags/search' => 'posts#search'
    # post_commentsルーティング
    post '/posts/:post_id/post_comments' => 'post_comments#create'
    delete '/posts/:post_id/post_comments/:id' => 'post_comments#destroy'
    # favoritesルーティング
    get '/posts/:post_id/favorites/index' => 'favorites#index'
    post '/posts/:post_id/favorites' => 'favorites#create'
    delete '/posts/:post_id/favorites/:id' => 'favorites#destroy'
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
    get '/posts/tags/search' => 'posts#search'
    # post_commentsルーティング
    delete '/posts/:post_id/post_comments/:id' => 'post_comments#destroy'
    # searchesルーティング
    get 'search', to: 'searches#search'
  end
  
end