class Public::SearchesController < ApplicationController
  before_action :authenticate_member!
  
  def search
    @model = params[:model]
    @content = params[:content]
    @method = params[:method]
    
    if @content.blank?
      flash.now[:alert] = "検索ワードを入力してください"
      render 'public/searches/search' and return
    end

    if @model == "Member"
      @members = Member.search_for(@content, @method)
      if @members.empty?
        flash.now[:alert] = "検索結果がありません"
      end
    else
      @records = Post.search_for(@content, @method)
      if @records.empty?
        flash.now[:alert] = "検索結果がありません"
      end
    end
    
    # @recordsがnilの場合、空の配列として扱う
    @records ||= []
  end
  
end