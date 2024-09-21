class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!
  
  def show
    @post = Post.find(params[:id])
    @post_tags = @post.tags
    @member = @post.member
  end

  def index
    # 全ユーザーの（公開中）リスト
    @all_published_posts = Post.where(post_status: 'published').order(created_at: :desc).page(params[:page]).per(10)
  end
  
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to admin_posts_path
  end

# タグ機能ここから------------------
  def tags
    # 公開中リストに関連付けられたタグ
    @tag_list = Tag.joins(:posts).where(posts: { post_status: 'published' }).distinct
    
    # タグが存在しているかの確認
    if params[:tag_id].present?
      @tag = Tag.find_by(id: params[:tag_id])
      if @tag.present?
        @posts = @tag.posts.order(created_at: :desc).page(params[:page]).per(10)
      else
        @posts = Post.none
      end
    else
      @tag = nil
      @posts = Post.none
    end
  end
  
  def destroy_tag
    @tag = Tag.find(params[:id])
    
    # タグに関連するリストがないことを確認
    if @tag.posts.empty?
      @tag.destroy
      flash[:notice] = "タグが削除されました。"
    else
      flash[:alert] = "関連する投稿があるため、タグを削除できません。"
    end
    redirect_to admin_posts_tags_search_path
  end
  
  def tags_search
    # 検索ワードが存在しているかの確認
    if params[:search].present?
      # タグを検索して該当するものがあるか確認
      @tag_list = Tag.where('tag_name LIKE ?', "%#{params[:search]}%").distinct # .distinct ＝ 重複するタグがある場合、一意なタグのみを取得
      # 該当するタグがあるか確認し、最初のタグを取得
      @tag = @tag_list.first if @tag_list.any?
      # 該当するタグに関連する投稿を取得し、投稿がない場合は空のリストを返す
      @posts = @tag.present? ? @tag.posts.order(created_at: :desc) : Post.none
    else
      @tag_list = Tag.all
      @posts = Post.none
    end
  end
  # ここまで-------------------------
end