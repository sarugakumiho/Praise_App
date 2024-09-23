class Public::RelationshipsController < ApplicationController
  before_action :authenticate_member!
  # ------------------------------------------------------------------------------------------------------------------
  def create
    member = Member.find(params[:member_id])
    current_member.follow(member)
    redirect_to request.referer
  end
  # ------------------------------------------------------------------------------------------------------------------
  def destroy
    member = Member.find(params[:member_id])
    current_member.unfollow(member)
    redirect_to request.referer
  end
  # ------------------------------------------------------------------------------------------------------------------
  def followings
    member = Member.find(params[:member_id])
    # フォローしている人数をカウント
    @total_followings_count = member.followings.where.not(id: current_member.id).count
    @members = member.followings.where.not(id: current_member.id).page(params[:page]).per(20)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def followers
    member = Member.find(params[:member_id])
    # フォロワーの人数をカウント
    @total_followers_count = member.followers.where.not(id: current_member.id).count
    @members = member.followers.where.not(id: current_member.id).page(params[:page]).per(20)
  end
  # ------------------------------------------------------------------------------------------------------------------
end
