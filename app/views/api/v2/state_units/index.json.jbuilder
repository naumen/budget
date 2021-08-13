json.array! @state_units do |state_unit|
  json.id          state_unit.get_root_parent_or_self_id
  json.cfo_id      state_unit.budget.cfo_id
  json.budget_id   state_unit.budget_id
  json.title       "#{state_unit.budget.cfo.name} / #{state_unit.position} (#{state_unit.division})"
  json.division    state_unit.division
  json.position    state_unit.position
  json.city_id     state_unit.city_office[0]
  json.office_id   state_unit.city_office[1]
  json.is_bind     state_unit.is_bind
  json.archive_date state_unit.archive_date
  json.date_closed  state_unit.date_closed
end
