class Public::MembersController < ApplicationController
  before_action :authenticate_member!, only: [:edit, :update]
  
  def my_page
    @member = current_member
  end

  def show
    @member = Member.find(params[:id])
    @published_posts = @member.posts.where(post_status: 'published').order(created_at: :desc)
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
      redirect_to my_page_members_path(@member), notice: "プロフィールが更新されました。"
    else
      render :edit
    end
  end

  def check
  end

  def out
  end

  private
  
  def member_params
    params.require(:member).permit(:name, :introduction, :email, :encrypted_password, :profile_image)
  end
end