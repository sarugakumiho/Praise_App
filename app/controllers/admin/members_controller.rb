class Admin::MembersController < ApplicationController
  before_action :authenticate_admin!
  
  def index
    @members = Member.all
  end

  def show
    @member = Member.find(params[:id])
    @published_posts = @member.posts.where(post_status: 'published').order(created_at: :desc).page(params[:unpublished_page])
  end

  def edit
    @member = Member.find(params[:id])
  end
  
  def update
    @member = Member.find(params[:id])
    if @member.update(member_params)
      puts @member.errors.full_messages
      redirect_to admin_member_path(@member.id)
    else
      render :edit
    end
  end
  
  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    flash[:notice] = "ユーザーを削除しました。"
    redirect_to admin_members_path
  end
  
  private
  
  def member_params
    params.require(:member).permit(:name, :introduction)
  end
  
end