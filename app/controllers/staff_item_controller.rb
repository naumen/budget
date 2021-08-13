class StaffItemController < ApplicationController

  def salaries
    @staff_item = StaffItem.find(params[:id])
  end

end
