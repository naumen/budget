json.array! @offices do |office|
  json.id office.id
  json.city_id office.city_id
  json.name office.name
  json.archived_at office.archived
end