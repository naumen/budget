class AddMaternityLeaveToMetrik < ActiveRecord::Migration[5.1]
  def change
    Metrik.create name: "Декретный отпуск", code: "maternity_leave"
  end
end
