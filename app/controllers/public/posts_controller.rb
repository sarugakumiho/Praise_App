class Public::PostsController < ApplicationController
  before_action :authenticate_member!
  before_action :ensure_correct_member, only: [:edit, :update, :destroy]
  
  def new
    @member = current_member
    @post = Post.new
    @post = @member.posts.new
  end

  def create
    @member = current_member
    @post = @member.posts.new(post_params)
    # タグ取得
    tag_list = params[:post][:tag_name].split(nil)  #送信されてきた値を「スペース」で区切って配列化

    # 投稿フォーム（日付・期間）の設定処理
    if @post.start_on.present?
      sabun = (@post.start_on - Date.today).to_i
      unless sabun >= 0
        flash[:error] = "開始日は本日以降で入力してください！"
        render :new and return
      end
    end
  
    if @post.start_on.present? && @post.end_on.present?
      sabun = (@post.end_on - @post.start_on).to_i
      unless sabun >= 0
        flash[:error] = "終了日は開始日以降で設定してください！"
        render :new and return
      end
    end
  
    # 投稿保存処理
    if @post.save
      @post.save_tag(tag_list)  #タグも保存
      flash[:notice] = "投稿が保存されました！"
      redirect_to post_path(@post) and return
    else
      render :new
    end
  end
  
  def show
   @post = Post.find(params[:id])
   @member = @post.member
   @post_tags = @post.tags
   @post_comment = PostComment.new
  end
  
  def index
    if params[:member_id].present?
      # 特定のメンバーの投稿
      @member = Member.find(params[:member_id])
      @published_posts = @member.posts.where(post_status: 'published').order(created_at: :desc).page(params[:published_page])
      @unpublished_posts = @member.posts.where(post_status: 'unpublished').order(created_at: :desc).page(params[:unpublished_page])
    else
      # 自分のリスト（公開中）とやることリスト（非公開）
      @published_posts = current_member.posts.where(post_status: 'published').order(created_at: :desc).page(params[:published_page])
      @unpublished_posts = current_member.posts.where(post_status: 'unpublished').order(created_at: :desc).page(params[:unpublished_page])
      
      # 全体の公開投稿
      @all_published_posts = Post.where(post_status: 'published').order(created_at: :desc).page(params[:all_published_page])
    end
  end

  def edit
    @post = Post.find(params[:id])
    @member = current_member
    # タグの編集
    @tag_list = @post.tags.pluck(:tag_name).join(nil)
  end

  def update
    @member = current_member
    @post = Post.find(params[:id])
    # tagの編集と削除
    tag_list = params[:post][:tag_name].split(nil)
    
    # 投稿編集処理
    if @post.update(post_params)
      old_relations = PostTag.where(post_id: @post.id)
      old_relations.each do |relation|
        relation.delete
      end
      @post.save_tag(tag_list)
      flash[:notice] = "編集しました！"
      redirect_to post_path(@post.id) and return
    else
      render :edit and return
    end
    
    # 公開設定処理
    @post.assign_attributes(post_params)
    
      if params[:unpublished].present?
        @post.post_status = :unpublished
        notice_message = "非公開にしました。"
        redirect_path = posts_path
      else
        @post.post_status = :published
        notice_message = "投稿を更新しました。"
        redirect_path = post_path(@post)
      end

      if @post.save
        redirect_to redirect_path, notice: notice_message and return
      else
        render :edit and return
      end
    
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path
  end

 # タグ機能ここから------------------
  def tags
    # 公開中の投稿に関連付けられたタグのみ取得
    @tag_list = Tag.joins(:posts).where(posts: { post_status: 'published' }).distinct
    @tag = Tag.find_by(id: params[:tag_id])
    
    if @tag.present?
      @posts = @tag.posts.where(post_status: 'published').order(created_at: :desc).page(params[:page])
    else
      flash[:alert] = "指定されたタグが見つかりません。"
      redirect_to posts_path
    end
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

  private
  
  def post_params
    params.require(:post).permit(:title, :start_on, :end_on, :memo, :image).merge(
      post_status: params[:post][:post_status].to_i,
      situation_status: params[:post][:situation_status].to_i
    )
  end
  
  def ensure_correct_member
    @post = Post.find(params[:id])
    unless @post.member == current_member
      redirect_to posts_path
    end
  end
  
end