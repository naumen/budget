json.array! @cities do |city|
  json.id city.id
  json.name city.name
  json.archived_at city.archive_date
end