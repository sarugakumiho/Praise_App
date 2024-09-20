class Public::FavoritesController < ApplicationController
  before_action :authenticate_member!
  
  def index
    @favorited_posts = Post.joins(:favorites).where(favorites: { member_id: current_member.id }).order(created_at: :desc).page(params[:page]).per(10)
  end

  def create
    @post = Post.find(params[:post_id])
    favorite = current_member.favorites.new(post_id: @post.id)
    favorite.save

    respond_to do |format|
      # 通常のHTMLリクエストの場合
      format.html { redirect_to post_path(@post) }
      # JavaScriptリクエスト（非同期処理/Ajax）の場合
      format.js
    end
  end

  def destroy
    @post = Post.find(params[:post_id])
    favorite = current_member.favorites.find_by(post_id: @post.id)
    favorite.destroy

    respond_to do |format|
      # 通常のHTMLリクエストの場合
      format.html { redirect_to post_path(@post) }
      # JavaScriptリクエスト（非同期処理/Ajax）の場合
      format.js
    end
  end
end