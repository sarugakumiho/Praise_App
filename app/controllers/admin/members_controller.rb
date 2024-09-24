class Admin::MembersController < ApplicationController
  before_action :authenticate_admin!
  # ------------------------------------------------------------------------------------------------------------------
  def index
    @members = Member.all.page(params[:page]).per(20)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def show
    @member = Member.find(params[:id])
    # ログインユーザーの（公開中）リスト
    @published_posts = @member.posts.where(post_status: 'published').order(created_at: :desc).page(params[:page]).per(10)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def edit
    @member = Member.find(params[:id])
  end
  # ------------------------------------------------------------------------------------------------------------------
  def update
    @member = Member.find(params[:id])
    if @member.update(member_params)
      flash[:notice] = "ユーザーのプロフィールを修正しました。"
      redirect_to admin_member_path(@member.id)
    else
      render :edit
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    flash[:notice] = "ユーザーを削除しました。"
    redirect_to admin_members_path
  end
  # ------------------------------------------------------------------------------------------------------------------
  private
  
  def member_params
    params.require(:member).permit(:name, :introduction)
  end
  # ------------------------------------------------------------------------------------------------------------------
end