class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!
  
  def top
    @members = Member.page(params[:page]).per(20)
    @all_published_posts = Post.where(post_status: 'published').order(created_at: :desc).page(params[:page]).per(10)
  end
  
end