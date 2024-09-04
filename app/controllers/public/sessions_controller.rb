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
  # 会員の論理削除のための記述
  # 退会後は、同じアカウントでの利用は不可
  def reject_member
    @member = Member.find_by(email: params[:member][:email])
    if @member
      if @member.valid_password?(params[:member][:password]) && (@member.is_active == false)
        flash[:notice] = "退会済みです。再度ご登録をしてご利用ください。"
        redirect_to new_member_registration_path and return
      else
        flash[:notice] = "項目を入力してください"
      end
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
