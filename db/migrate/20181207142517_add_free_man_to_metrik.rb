class AddFreeManToMetrik < ActiveRecord::Migration[5.1]
  def change
    Metrik.create name: "Свободный человек", code: "free_man"
  end
end
