require 'import_data'

class ImportController < ApplicationController
  def index
  end

  def do_import
    if params[:kind] == 'budget2018_itogo'
      Budget.init_itogo_usage_2018
    elsif params[:kind] == 'budget2019_itogo'
      Budget.init_itogo_usage_2019
    else
      ImportData.do_import(params[:kind])
    end
    redirect_to '/import', success: 'Обновление закончено'
  end

  def allow?(user)
    user.is_admin?
  end

end