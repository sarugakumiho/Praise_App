class Public::ExpenditureCostsController < ApplicationController
  before_action :authenticate_member!
  # ログインユーザーのみ操作可能
  before_action :ensure_correct_member, only: [:edit, :update, :destroy]
  # ------------------------------------------------------------------------------------------------------------------
  def new
    @expenditure_cost = ExpenditureCost.new
  end
  # ------------------------------------------------------------------------------------------------------------------
  def create
    @expenditure_cost = ExpenditureCost.new(expenditure_cost_params)
    @expenditure_cost.member = current_member
    if @expenditure_cost.save
      flash[:notice] = "追加しました！"
      redirect_to expenditure_costs_path
    else
      render :new
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def index
    # ソート設定
    sort_order = params[:sort_order] == 'asc' ? 'asc' : 'desc'
    @expenditure_costs = ExpenditureCost.where(member: current_member).order(date: sort_order).page(params[:page]).per(50)
  
    # 各月ごとに金額を集計
    if Rails.env.development?
      @monthly_expenditure = ExpenditureCost.where(member: current_member).group("strftime('%Y-%m', date)").sum(:price)
    else
      @monthly_expenditure = ExpenditureCost.where(member: current_member).group("DATE_FORMAT(date, '%Y-%m')").sum(:price)
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def edit
    @expenditure_cost = ExpenditureCost.find(params[:id])
  end
  # ------------------------------------------------------------------------------------------------------------------
  def update
    @expenditure_cost = ExpenditureCost.find(params[:id])
    if @expenditure_cost.update(expenditure_cost_params)
      flash[:notice] = "更新しました！"
      redirect_to expenditure_costs_path
    else
      render :edit
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def destroy
    @expenditure_cost = ExpenditureCost.find(params[:id])
    @expenditure_cost.destroy
    flash[:notice] = "削除しました。"
    redirect_to expenditure_costs_path
  end
  # ------------------------------------------------------------------------------------------------------------------
  private

  def expenditure_cost_params
    params.require(:expenditure_cost).permit(:category, :expenses_name, :price, :date)
  end
  
  # ログインユーザーのみ操作可能
  def ensure_correct_member
    @expenditure_cost = ExpenditureCost.find(params[:id])
    unless @expenditure_cost.member == current_member
      redirect_to expenditure_costs_path
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
end