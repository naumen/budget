class DatabasesController < ApplicationController
  def switch
    Database.snapshot!
    redirect_to root_path
  end

  def switch_reset
    Database.development!
    redirect_to root_path
  end
end
