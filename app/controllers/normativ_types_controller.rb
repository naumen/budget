class NormativTypesController < ApplicationController
  before_action :set_normativ_type, only: [:edit, :update, :destroy]

  def index
    @normativ_types = NormativType.all
  end

  def new
    @normativ_type = NormativType.new
  end

  def create
    @normativ_type = NormativType.new(normativ_type_params)

    if @normativ_type.save
      redirect_to normativ_types_path, success: 'Тип норматива создана'
    else
      flash.now[:danger] = 'Тип норматива не создана'
      render :new
    end
  end

  def edit;  end

  def update
    if @normativ_type.update(normativ_type_params)
      redirect_to normativ_types_path, success: 'Тип норматива обновлен'
    else
      flash.now[:danger] = 'Тип норматива не обновлен'
      render :edit
    end
  end

  def destroy
    if @normativ_type.destroy
      redirect_to normativ_types_path, success: 'Тип норматива удален'
    else
      redirect_to normativ_types_path, danger: 'Тип норматива не удален'
    end
  end

  private

  def set_normativ_type
    @normativ_type = NormativType.find(params[:id])
  end

  def normativ_type_params
    params.require(:normativ_type).permit(:name)
  end
end