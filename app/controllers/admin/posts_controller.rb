class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!
  
  def show
   @post = Post.find(params[:id])
   @member = @post.member
   @post_tags = @post.tags
    
  end

  def index
    # 全体の公開投稿
    @all_published_posts = Post.where(post_status: 'published').order(created_at: :desc).page(params[:page]).per(10)
  end
  
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to admin_posts_path
  end

# タグ機能ここから------------------
  def tags
    # 公開中の投稿に関連付けられたタグのみ取得
    @tag_list = Tag.joins(:posts).where(posts: { post_status: 'published' }).distinct
    
    if params[:tag_id].present?
      @tag = Tag.find_by(id: params[:tag_id])
    
      if @tag.present?
        @posts = @tag.posts.order(created_at: :desc).page(params[:page]).per(10)
      else
        @posts = Post.none
      end
    else
      # タグが指定されていない場合は全タグを表示
      @tag = nil
      @posts = Post.none
    end
  end
  
  # タグ削除（管理者のみ）
  def destroy_tag
    @tag = Tag.find(params[:id])
    if @tag.posts.empty?
      @tag.destroy
      flash[:notice] = "タグが削除されました。"
    else
      flash[:alert] = "関連する投稿があるため、タグを削除できません。"
    end
    redirect_to admin_posts_tags_search_path
  end
  
  def search
    # 検索キーワードが渡されているか確認
    if params[:search].present?
      # タグ名に検索キーワードが含まれるタグを取得
      @tag_list = Tag.where('tag_name LIKE ?', "%#{params[:search]}%").distinct
      @tag = @tag_list.first if @tag_list.any? # タグがあれば最初のタグを取得
      @posts = @tag.present? ? @tag.posts.order(created_at: :desc) : Post.none
    else
      # 検索ワードが空の場合、エラーメッセージを設定
      flash.now[:alert] = "タグ名を入力してください"
      @tag_list = Tag.all # 全てのタグを表示
      @posts = Post.none # 空の投稿リストを設定
    end
  end
  # ここまで-------------------------
  
end