json.array! @users do |user|
  json.id user.id
  json.login user.login
  json.l_name user.l_name
  json.f_name user.f_name
  json.s_name user.s_name
  json.archived_at user.archive_date
end