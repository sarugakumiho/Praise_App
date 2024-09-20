class Admin::SearchesController < ApplicationController
  before_action :authenticate_admin!
  
  def search
    @model = params[:model]
    @content = params[:content]
    @method = params[:method]
    
    # 入力の有無を確認
    if @content.blank?
      flash.now[:alert] = "検索ワードを入力してください"
      render 'admin/searches/search' and return
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
  end
  
end