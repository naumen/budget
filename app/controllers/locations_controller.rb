class LocationsController < ApplicationController
  before_action :set_location, only: [:edit, :update, :destroy]

  def index
    @locations = Location.active
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      redirect_to locations_path, success: 'Локация создана'
    else
      flash.now[:danger] = 'Локация не создана'
      render :new
    end
  end

  def edit; end

  def update
    if @location.update(location_params)
      redirect_to locations_path, success: 'Локация обновлена'
    else
      flash.now[:danger] = 'Локация не обновлена'
      render :edit
    end
  end

  def destroy
    if @location.archive!
      redirect_to locations_path, success: 'Локация удалена'
    else
      redirect_to locations_path, danger: 'Локация не удалена'
    end
  end

  private

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :city_id)
  end
end