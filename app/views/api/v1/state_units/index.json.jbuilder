json.array! @state_units do |state_unit|
  json.id          state_unit.id
  json.budget_name state_unit.budget.name
  json.position    state_unit.position
  json.division    state_unit.division
  json.location_id state_unit.location_id
  json.location_name state_unit.location.name
  json.salaries    state_unit.salaries_as_array
  json.fzp         state_unit.fzp
end