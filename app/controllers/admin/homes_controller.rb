class Admin::HomesController < ApplicationController
  before_action :authenticate_admin!
  
  def top
    @members = Member.page(params[:page])
    @all_published_posts = Post.where(post_status: 'published').order(created_at: :desc).page(params[:all_published_page])
  end
  
end