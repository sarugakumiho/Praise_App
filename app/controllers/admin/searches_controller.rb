class Admin::SearchesController < ApplicationController
  before_action :authenticate_admin!
  
  def search
    @model = params[:model]
    @content = params[:content]
    @method = params[:method]
    
    # 検索モデルが「Member」の時とそうでない場合の時「Post」の処理
    if @model == "Member"
      @members = Member.search_for(@content, @method).page(params[:page]).per(20)
    else
      @records = Post.search_for(@content, @method).page(params[:page]).per(10)
    end
      
    # @recordsがnilの場合、空の配列として扱う
    @records ||= []
  end
  
end