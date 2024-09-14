class Admin::PostCommentsController < ApplicationController
  
  def index
    @post_comments = PostComment.includes(:post, :member).all
  end
  
  def destroy
    post_comment = PostComment.find_by(id: params[:id])
    
    if post_comment.nil?
      flash[:alert] = "コメントが見つかりません。"
      redirect_to admin_post_path
      return
    end
    
    post = post_comment.post
    post_comment.destroy
    flash[:notice] = "コメントを削除しました。"
    redirect_to admin_post_path(post)
  end
  
end