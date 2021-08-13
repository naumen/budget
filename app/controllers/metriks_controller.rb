class MetriksController < ApplicationController
  before_action :set_metrik, only: [:edit, :update, :destroy]

  def index
    @metriks = Metrik.all
  end

  def new
    @metrik = Metrik.new
  end

  def create
    @metrik = Metrik.new(metrik_params)

    if @metrik.save
      redirect_to metriks_path, success: 'Метрика создана'
    else
      flash.now[:danger] = 'Метрика не создана'
      render :new
    end
  end

  def edit; end

  def update
    if @metrik.update(metrik_params)
      redirect_to metriks_path, success: 'Метрика обновлена'
    else
      flash.now[:danger] = 'Метрика не обновлена'
      render :edit
    end
  end

  def destroy
    if @metrik.destroy
      redirect_to metriks_path, success: 'Метрика удалена'
    else
      redirect_to metriks_path, danger: 'Метрика не удалена'
    end
  end


  private

  def set_metrik
    @metrik = Metrik.find(params[:id])
  end

  def metrik_params
    params.require(:metrik).permit(:name, :code)
  end
end