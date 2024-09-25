class Public::ExpenditureCostsController < ApplicationController
  before_action :authenticate_member!
  # ------------------------------------------------------------------------------------------------------------------
  def new
    @expenditure_cost = ExpenditureCost.new
  end
  # ------------------------------------------------------------------------------------------------------------------
  def create
    @expenditure_cost = ExpenditureCost.new(expenditure_cost_params)
    if @expenditure_cost.save
      flash[:notice] = "追加しました！"
      redirect_to expenditure_costs_path
    else
      render :new
    end
  end
  # ------------------------------------------------------------------------------------------------------------------
  def index
    @expenditure_costs = ExpenditureCost.all.order(date: :desc).page(params[:page]).per(50)
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
  # ------------------------------------------------------------------------------------------------------------------
end