class Admin::PostsController < ApplicationController
  
  def show
   @post = Post.find(params[:id])
   @member = @post.member
   @post_tags = @post.tags
    
  end

  def index
    # 全体の公開投稿
    @all_published_posts = Post.where(post_status: 'published').order(created_at: :desc).page(params[:all_published_page])
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
        @posts = @tag.posts.where(post_status: 'published').order(created_at: :desc).page(params[:page])
      else
        flash[:alert] = "指定されたタグが見つかりません。"
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
    redirect_to tags_admin_posts_path
  end
  
  def search
    # 検索キーワードが渡されているか確認
    if params[:search].present?
      # タグ名に検索キーワードが含まれるタグを取得
      @tag_list = Tag.where('tag_name LIKE ?', "%#{params[:search]}%").distinct
      
      if @tag_list.any?
        @tag = @tag_list.first
        @posts = @tag.posts.where(post_status: 'published').order(created_at: :desc).page(params[:page])
      else
        @posts = Post.none # 検索結果がない場合は空のリスト
      end
    else
      @tag_list = Tag.all
      @posts = Post.none
    end
  end
  # ここまで-------------------------
  
end