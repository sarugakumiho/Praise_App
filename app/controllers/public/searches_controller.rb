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
    
    # 検索モデルが「Member」の時とそうでない場合の時「Post」の処理
    if @model == "Member"
      @members = Member.search_for(@content, @method).page(params[:page]).per(20)
      if @members.empty?
        flash.now[:alert] = "検索結果がありません"
      end
    else
      @records = Post.search_for(@content, @method).page(params[:page]).per(10)
      if @records.empty?
        flash.now[:alert] = "検索結果がありません"
      end
    end
    
    # @recordsがnilの場合、空の配列として扱う
    @records ||= []
  end
  
end