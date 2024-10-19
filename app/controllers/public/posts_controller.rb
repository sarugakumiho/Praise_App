class Public::PostsController < ApplicationController
  before_action :authenticate_member!
  # ログインユーザーのみ操作可能
  before_action :ensure_correct_member, only: [:edit, :update, :destroy]
  # ------------------------------------------------------------------------------------------------------------------
  def new
    @member = current_member
    @post = Post.new
    @post = @member.posts.new
  end
  # ------------------------------------------------------------------------------------------------------------------
  def create
    @member = current_member
    @post = @member.posts.new(post_params)
    tag_list = params[:post][:tag_name].split(nil)
    
    # 終了日が開始日以降かどうかを確認
    if @post.start_on.present? && @post.end_on.present?
      sabun = (@post.end_on - @post.start_on).to_i
      unless sabun >= 0
        flash.now[:alert] = "終了日は開始日以降で設定してください。" 
        render :new and return
      end
    end
    
    # 保存処理
    if @post.save
      # タグも保存
      @post.save_tag(tag_list) 
      flash[:notice] = "リストが保存されました！"
      redirect_to post_path(@post) and return
    else
      flash.now[:alert] = "リストの保存に失敗しました。"
      render :new
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def show
   @post = Post.find(params[:id])
   @member = @post.member
   @post_tags = @post.tags
   @post_comment = PostComment.new
  end
  # ------------------------------------------------------------------------------------------------------------------
  def index
    # ログインユーザーの（公開中）リスト
    @published_posts = current_member.posts.where(post_status: 'published')
                                           .order(created_at: :desc).page(params[:published_page]).per(10)
    # ログインユーザーの(非公開)やることリスト
    @unpublished_posts = current_member.posts.where(post_status: 'unpublished')
                                             .order(created_at: :desc).page(params[:unpublished_page]).per(10)
    # 全ユーザーの（公開中）リスト
    @all_published_posts = Post.where(post_status: 'published')
                               .order(created_at: :desc).page(params[:all_published_page]).per(10)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def edit
    @post = Post.find(params[:id])
    # リストに関連付けられているタグの一覧を取得
    @tag_list = @post.tags.pluck(:tag_name).join(' ') 
  end
  # ------------------------------------------------------------------------------------------------------------------
  def update
    @post = Post.find(params[:id])
    
    # tagの編集と削除
    tag_list = params[:post][:tag_name].split(nil)
    
    if @post.update(post_params)
      # 既存のタグを削除
      old_relations = PostTag.where(post_id: @post.id)
      old_relations.each do |relation|
        relation.delete
      end
      
      # 終了日が開始日以降かどうかを確認
      if @post.start_on.present? && @post.end_on.present?
        sabun = (@post.end_on - @post.start_on).to_i
        unless sabun >= 0
          flash[:alert] = "終了日は開始日以降で設定してください。"
          render :edit and return
        end
      end
      
      # 新しいタグを保存
      @post.save_tag(tag_list)
      flash[:notice] = "編集しました！"
      redirect_to post_path(@post.id) and return
    else
      render :edit
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    flash[:notice] = "リストを削除しました。"
    redirect_to posts_path
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
        # 存在する場合、指定されたタグを取得し、関連する公開中の投稿を表示
        @posts = @tag.posts.where(post_status: 'published').order(created_at: :desc).page(params[:page]).per(10)
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
  def tags_search
    # TagモデルとPostモデルを結合し、公開中リストに関連付けられたタグを一覧で取得
    @tag_list = Tag.joins(:posts).where(posts: { post_status: 'published' }).distinct
    
    # 検索ワードが存在しているかの確認
    if params[:search].present?
      # 検索ワードを含むタグを部分一致で取得
      @tag_list = @tag_list.where('tag_name LIKE ?', "%#{params[:search]}%")
      # 複数のタグが見つかった場合に最初のタグを選択し、それに関連する投稿を表示するため、最初のタグを@tagに設定
      @tag = @tag_list.first
      # 検索結果として@tagが設定されているかを確認
      if @tag.present?
        # 該当するタグに関連する公開リストを取得
        @posts = @tag.posts.where(post_status: 'published').order(created_at: :desc)
      else
        flash.now[:alert] = "該当するタグが見つかりません。"
      end
    end
  end
  # ここまで↑
  # ------------------------------------------------------------------------------------------------------------------
  private
  
  def post_params
    params.require(:post).permit(:title, :start_on, :end_on, :memo, :image).merge(
      post_status: params[:post][:post_status].to_i,
      situation_status: params[:post][:situation_status].to_i
    )
  end
  
  # ログインユーザーのみ操作可能
  def ensure_correct_member
    @post = Post.find(params[:id])
    unless @post.member == current_member
      redirect_to posts_path
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
end