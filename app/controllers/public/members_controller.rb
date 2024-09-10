class Public::MembersController < ApplicationController
  before_action :authenticate_member!, only: [:edit, :update]
  
  def my_page
    @member = current_member
    # やることリスト（非公開）
    @unpublished_posts = @member.posts.where(post_status: 'unpublished').order(created_at: :desc).page(params[:unpublished_page])
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
      redirect_to my_page_members_path(@member)
    else
      render :edit
    end
  end

  def check
  end

  def out
    @member = Member.find(params[:id])
    @member.update(is_active: false)
    reset_session
    flash[:notice] = "退会しました！"
    redirect_to root_path
  end

  private
  
  def member_params
    params.require(:member).permit(:name, :introduction, :email, :encrypted_password, :profile_image)
  end
end