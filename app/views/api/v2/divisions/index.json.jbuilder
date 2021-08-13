json.array! @divisions do |division|
  json.id   division.id
  json.kind division.kind
  json.name division.name
  json.chief_id division.chief_id
  json.parent_id division.parent_id
  json.archived_at division.archived
end