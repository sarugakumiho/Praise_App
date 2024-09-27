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
    @member = current_member
    # タグの編集
    @tag_list = @post.tags.pluck(:tag_name).join(' ') # .join(' ') = タグをスペースで結合して表示
  end
  # ------------------------------------------------------------------------------------------------------------------
  def update
    @member = current_member
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
    redirect_to my_page_members_path
  end
  # ------------------------------------------------------------------------------------------------------------------
  # タグ機能ここから↓
  def tags
    # タグの一覧を取得
    @tag_list = Tag.joins(:posts).where(posts: { post_status: 'published' }).distinct

    if params[:tag_id].present?
      # 指定されたタグを取得
      @tag = Tag.find_by(id: params[:tag_id])

      if @tag.present?
        # 該当するタグに紐づく公開中の投稿を取得
        @posts = @tag.posts.where(post_status: 'published').order(created_at: :desc).page(params[:page]).per(10)
      else
        @posts = Post.none
        flash.now[:alert] = "該当するタグが見つかりません。"
      end
    else
      @posts = Post.none
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def tags_search
    # タグ一覧は常に取得
    @tag_list = Tag.joins(:posts).where(posts: { post_status: 'published' }).distinct
  
    if params[:search].present?
      # 検索されたタグを取得
      @tag_list = @tag_list.where('tag_name LIKE ?', "%#{params[:search]}%")
      @tag = @tag_list.first
  
      if @tag.present?
        # 該当するタグの投稿を取得
        @posts = @tag.posts.where(post_status: 'published').order(created_at: :desc)
      else
        @posts = Post.none
        flash.now[:alert] = "該当するタグが見つかりません。"
      end
    else
      @posts = Post.none
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