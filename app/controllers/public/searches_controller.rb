class Public::SearchesController < ApplicationController
  before_action :authenticate_member!
  # ------------------------------------------------------------------------------------------------------------------
  def search
    @model = params[:model]
    # @content=検索キーワード
    @content = params[:content]
    # @method=検索方法
    @method = params[:method]
    
    # 検索モデルが「Member」の時とそうでない場合の時「Post」の処理
    if @model == "Member"
      @members = Member.search_for(@content, @method).page(params[:page]).per(20)
      if @members.empty?
        flash.now[:alert] = "検索結果がありません。"
      end
    else
      @posts = Post.search_for(@content, @method).page(params[:page]).per(10)
      if @posts.empty?
        flash.now[:alert] = "検索結果がありません。"
      end
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
end