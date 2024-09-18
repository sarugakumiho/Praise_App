class Public::MembersController < ApplicationController
  before_action :authenticate_member!
  before_action :ensure_guest_member, only: [:edit, :update] # ゲストログイン制限設定
  
  def my_page
    @member = current_member
    # 自分のリスト（公開中）
    @published_posts = @member.posts.where(post_status: 'published').order(created_at: :desc).page(params[:published_page])
    # 自分のやることリスト（非公開）
    @unpublished_posts = @member.posts.where(post_status: 'unpublished').order(created_at: :desc).page(params[:unpublished_page])
    
    # タイムライン設定
    # フォローしているユーザーのIDを取得
    @follow_members = current_member.followings.pluck(:id)                      
    @all_published_posts = Post.where(member_id: @follow_members, post_status: 'published')
                           .from_last_week
                           .order(created_at: :desc)
                           .page(params[:all_published_page])
  end

  def show
    @member = Member.find(params[:id])
    # 特定のメンバーの投稿
    @published_posts = @member.posts.where(post_status: 'published').order(created_at: :desc).page(params[:unpublished_page])
  end

  def index
    @members = Member.all
  end

  def edit
    @member = current_member
  end

  def update
    @member = current_member
    
    # プロフィール編集処理
    if @member.update(member_params)
      flash[:notice] = "プロフィールが更新されました！"
      redirect_to my_page_members_path
    else
      render :edit
    end
  end
  
  def destroy
    @member = Member.find(current_member.id)
    @member.destroy
    flash[:notice] = "退会しました。"
    redirect_to new_member_registration_path
  end

  private
  
  def member_params
    params.require(:member).permit(:name, :introduction, :email, :encrypted_password, :profile_image, :is_active)
  end
  
  # ゲストログイン制限設定
  def ensure_guest_member
    if current_member.guest_member?
      redirect_to member_path(current_member), notice: "ゲストユーザーはプロフィール編集画面へ遷移できません。"
    end
  end
end