class SprCfoTypesController < ApplicationController
  before_action :set_cfo_type, only: [:destroy, :edit, :update]

  def index
    @cfo_types = SprCfoType.all
  end

  def new
    @cfo_type = SprCfoType.new
  end

  def create
    @cfo_type = SprCfoType.new(cfo_type_params)

    if @cfo_type.save
      redirect_to spr_cfo_types_path, success: 'Тип ЦФО создан'
    else
      flash.now[:danger] = 'Тип ЦФО не создан'
      render :new
    end
  end

  def edit;  end

  def update
    if @cfo_type.update(cfo_type_params)
      redirect_to spr_cfo_types_path, success: 'Тип ЦФО обновлен'
    else
      flash.now[:danger] = 'Тип ЦФО не обновлен'
      render :edit
    end
  end

  def destroy
    if @cfo_type.destroy
      redirect_to spr_cfo_types_path, success: 'Тип ЦФО удален'
    else
      redirect_to spr_cfo_types_path, danger: 'Тип ЦФО не удален'
    end
  end

  private

  def set_cfo_type
    @cfo_type = SprCfoType.find(params[:id])
  end

  def cfo_type_params
    params.require(:spr_cfo_type).permit(:name)
  end
end