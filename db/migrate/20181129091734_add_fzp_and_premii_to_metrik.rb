class AddFzpAndPremiiToMetrik < ActiveRecord::Migration[5.1]
  def change
    Metrik.create name: "ФЗП и Премии Бюджета", code: "fzp_and_premii"
  end
end
