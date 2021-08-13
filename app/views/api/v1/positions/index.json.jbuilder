json.array! @positions do |position|
  json.id   position.id
  json.name position.name
  json.archived_at position.archived
end