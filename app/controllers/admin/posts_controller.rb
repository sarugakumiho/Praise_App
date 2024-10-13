class Admin::PostsController < ApplicationController
  before_action :authenticate_admin!
  # ------------------------------------------------------------------------------------------------------------------
  def show
    @post = Post.find(params[:id])
    @post_tags = @post.tags
    @member = @post.member
  end
  # ------------------------------------------------------------------------------------------------------------------
  def index
    # 全ユーザーの（公開中）リスト
    @all_published_posts = Post.where(post_status: 'published').order(created_at: :desc).page(params[:page]).per(10)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:notice] = "リストが削除されました。"
    redirect_to admin_posts_path
  end
  # ------------------------------------------------------------------------------------------------------------------
  # タグ機能ここから↓
  def tags
    # TagモデルとPostモデルを結合し、公開中リストに関連付けられたタグを一覧で取得
    @tag_list = Tag.joins(:posts).where(posts: { post_status: 'published' }).distinct

    # リクエストでtag_idが指定されているかを確認
    # 指定されていれば以下の処理（タグの取得と投稿の表示）へ進む
    if params[:tag_id].present?
      # 指定されたタグを取得
      @tag = Tag.find_by(id: params[:tag_id])
      # 上記タグが存在するかを確認
      if @tag.present?
        # 存在する場合、指定されたタグを取得し、関連する投稿を表示
        @posts = @tag.posts.order(created_at: :desc).page(params[:page]).per(10)
      else
        # 存在しても、実際にはデータベースにそのIDに対応するタグが存在しない場合がある。
        # その場合は空の投稿リストを返す。
        @posts = Post.none
      end
    else
      # @tagをnilに設定することで、「現在表示するタグは存在しない」という状態を明示的に示す
      @tag = nil
      # 存在しないタグに対応する投稿リストが空であることを示す
      @posts = Post.none
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def destroy_tag
    @tag = Tag.find(params[:id])
    
    # タグに関連するリストがないことを確認
    # @tagが関連する投稿を持っていない場合にのみ、タグを削除
    if @tag.posts.empty?
      @tag.destroy
      flash[:notice] = "タグが削除されました。"
    # @tagが関連する投稿がある場合は削除しない
    else
      flash[:alert] = "関連する投稿があるため、タグを削除できません。"
    end
    redirect_to admin_posts_tags_search_path
  end
  # ------------------------------------------------------------------------------------------------------------------
  def tags_search
    # 検索ワードが存在しているかの確認
    if params[:search].present?
      # 検索ワードを含むタグを部分一致で取得
      @tag_list = Tag.where('tag_name LIKE ?', "%#{params[:search]}%").distinct
      # 複数のタグが見つかった場合に最初のタグを選択し、それに関連する投稿を表示するため、最初のタグを@tagに設定
      @tag = @tag_list.first
      # 検索結果として@tagが設定されているかを確認
      if @tag.present?
        # 該当するタグに関連するリストを取得
        @posts = @tag.posts.order(created_at: :desc)
      else
        flash.now[:alert] = "該当するタグが見つかりません。"
      end
    else
      # 検索ワードが空であればすべてのタグを取得
      @tag_list = Tag.all
    end
  end
  # ここまで↑
  # ------------------------------------------------------------------------------------------------------------------
end