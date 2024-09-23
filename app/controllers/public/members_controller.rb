class Public::MembersController < ApplicationController
  before_action :authenticate_member!
  # ゲストログイン制限設定
  before_action :ensure_guest_member, only: [:edit, :update]
  # ------------------------------------------------------------------------------------------------------------------
  def my_page
    @member = current_member
    # ログインユーザーの（公開中）リスト
    @published_posts = @member.posts.where(post_status: 'published').order(created_at: :desc)
                              .page(params[:published_page]).per(10)
    # ログインユーザーの（非公開）やることリスト
    @unpublished_posts = @member.posts.where(post_status: 'unpublished').order(created_at: :desc)
                                .page(params[:unpublished_page]).per(10)
    # タイムライン表示（フォローしているユーザーの（公開中）リスト）
    @follow_members = current_member.followings.pluck(:id)
    @all_published_posts = Post.where(member_id: @follow_members, post_status: 'published')
                               .from_last_week
                               .order(created_at: :desc)
                               .page(params[:all_published_page])
                               .per(10)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def show
    @member = Member.find(params[:id])
    # 特定のユーザーの（公開中）リスト
    @published_posts = @member.posts.where(post_status: 'published')
                              .order(created_at: :desc).page(params[:page]).per(10)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def index
    @members = Member.all.page(params[:page]).per(20)
  end
  # ------------------------------------------------------------------------------------------------------------------
  def edit
    @member = current_member
  end
  # ------------------------------------------------------------------------------------------------------------------
  def update
    @member = current_member
    if @member.update(member_params)
      flash[:notice] = "プロフィールが更新されました！"
      redirect_to my_page_members_path
    else
      render :edit
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def destroy
    @member = Member.find(current_member.id)
    @member.destroy
    flash[:notice] = "退会しました。"
    redirect_to new_member_registration_path
  end
  # ------------------------------------------------------------------------------------------------------------------
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
  # ------------------------------------------------------------------------------------------------------------------
end