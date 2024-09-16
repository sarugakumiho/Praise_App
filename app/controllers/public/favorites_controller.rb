class Public::FavoritesController < ApplicationController
  before_action :authenticate_member!
  
  def index
    # ログインユーザーがいいねした投稿を取得
    @favorited_posts = current_member.favorites.includes(:post).map(&:post)
  end

  def create
    post = Post.find(params[:post_id])
    favorite = current_member.favorites.new(post_id: post.id)
    favorite.save
    redirect_to post_path(post)
  end

  def destroy
    post = Post.find(params[:post_id])
    favorite = current_member.favorites.find_by(post_id: post.id)
    favorite.destroy
    redirect_to post_path(post)
  end
end