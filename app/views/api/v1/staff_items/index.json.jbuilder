json.array! @staff_items do |staff_item|
  json.id          staff_item.id
  json.position_id staff_item.position_id
  json.division_id staff_item.division_id
  json.office_id   staff_item.location_id
  json.city_id     staff_item.city_id
  json.koeff       staff_item.koeff
  json.archived_at staff_item.archived
end