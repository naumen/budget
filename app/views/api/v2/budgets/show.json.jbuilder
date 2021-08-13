json.name @budget.name
json.plan_marga @presenter.budget_info.plan_marga.to_i 
json.in_itogo  @presenter.budget_info.in.itogo.to_i
json.out_itogo @presenter.budget_info.out.itogo.to_i
json.out_own_nakladn @presenter.budget_info.out.own.nakladn.to_i

nakladn_array = []
@presenter.nakladn_groups.each do |code, name|
  rows, itogo = @presenter.nakladn_by_group(code)
  # next if itogo.summ == 0.0
  nakladn_array << { code: code, summ: itogo.summ.to_i}
end

json.nakladn_items nakladn_array, :code, :summ
