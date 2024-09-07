class Public::MembersController < ApplicationController
  
  def my_page
    @member = current_member
  end

  def show
  end

  def index
  end

  def edit
    @member = current_member
  end

  def update
    @member = current_member
    
    # プロフィール編集処理
    if @member.update(member_params)
      redirect_to my_page_members_path(@member)
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