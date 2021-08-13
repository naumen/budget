class SaleChannelsController < ApplicationController

  def index
    @sale_channels = SaleChannel.sorted
  end

  def new
    @sale_channel = SaleChannel.new
  end

  def create
    @sale_channel = SaleChannel.new(sale_channel_params)
    @sale_channel.f_year = session[:f_year]

    if @sale_channel.save
      redirect_to new_sale_path, success: 'Канал продаж добавлен'
    else
      flash.now[:danger] = 'Канал продаж не добавлен'
      render :new
    end
  end

  def destroy
    @sale_channel = SaleChannel.find(params[:id])

    if @sale_channel.update(archived_date: Date.current)
      redirect_to sale_channels_path, success: 'Канал продаж отправлен в архив'
    end
  end

  private
  def sale_channel_params
    params.require(:sale_channel).permit(:name)
  end
end
