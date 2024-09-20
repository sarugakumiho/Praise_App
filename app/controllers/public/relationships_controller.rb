class Public::RelationshipsController < ApplicationController
  before_action :authenticate_member!
  
  def create
    member = Member.find(params[:member_id])
    current_member.follow(member)
    redirect_to request.referer
  end

  def destroy
    member = Member.find(params[:member_id])
    current_member.unfollow(member)
    redirect_to request.referer
  end

  def followings
    member = Member.find(params[:member_id])
    # フォローしている人数の合計
    @total_followings_count = member.followings.count
    @members = member.followings.page(params[:page]).per(20)
  end
  
  def followers
    member = Member.find(params[:member_id])
    # フォワーの人数の合計
    @total_followers_count = member.followers.count
    @members = member.followers.page(params[:page]).per(20)
  end
  
end