class SprStatZatrsController < ApplicationController
  before_action :set_spr_stat_zatr, only: [:edit, :update, :destroy]

  def index
    @spr_stat_zatrs = SprStatZatr.active
  end

  def new
    @spr_stat_zatr = SprStatZatr.new
  end

  def create
    @spr_stat_zatr = SprStatZatr.new(spr_stat_zatr_params)

    if @spr_stat_zatr.save
      redirect_to spr_stat_zatrs_path, success: 'Запись создана'
    else
      flash.now[:danger] = 'Ошибка'
      render :new
    end
  end

  def edit; end

  def update
    if @spr_stat_zatr.update(spr_stat_zatr_params)
      redirect_to spr_stat_zatrs_path, success: 'Запись обновлена'
    else
      flash.now[:danger] = 'Ошибка'
      render :edit
    end
  end

  def destroy
    if @spr_stat_zatr.archive!
      redirect_to spr_stat_zatrs_path, success: 'Запись удалена'
    else
      redirect_to spr_stat_zatrs_path, danger: 'Ошибка'
    end
  end

  private

  def set_spr_stat_zatr
    @spr_stat_zatr = SprStatZatr.find(params[:id])
  end

  def spr_stat_zatr_params
    params.require(:spr_stat_zatr).permit(:name, :city_id)
  end
end