# frozen_string_literal: true

class Public::SessionsController < Devise::SessionsController
  # reject_member:特定の条件に基づいて、リクエストを拒否またはリダイレクトするためのメソッド
  # 会員ステータスに応じた動きにするため、configure_sign_in_paramsではなくreject_member
  before_action :reject_member, only: [:create]  

  def after_sign_in_path_for(resource)
    my_page_members_path
  end

  def after_sign_out_path_for(resource)
    about_path
  end
  
  # ゲストログイン
  def guest_sign_in
    member = Member.guest
    sign_in member
    redirect_to my_page_members_path(member), notice: "ゲストとしてログインしました！"
  end
  
    protected
  # 会員のログインを制限するための記述
  def reject_member
    @member = Member.find_by(email: params[:member][:email])
    if @member
      if @member.valid_password?(params[:member][:password])
      else
        flash[:notice] = "パスワードが正しくありません。"
        redirect_to new_member_session_path and return
      end
    else
      flash[:notice] = "該当するアカウントが存在しません。"
      redirect_to new_member_session_path and return
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
