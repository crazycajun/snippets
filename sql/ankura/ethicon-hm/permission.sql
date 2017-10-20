SELECT
  u.email
  ,u.first_name
  ,u.last_name
  ,silos.name as silo
  ,roles.name as role
  ,p.feature
  ,p.resource
from
  users u
  join user_roles ur on
    u.id = ur.user_id
  join roles on
    ur.role_id = roles.id
  join role_permissions rp on
    roles.id = rp.role_id
  join permissions p on
    rp.permission_id = p.id
  join silos on
    roles.silo_id = silos.id
where
  p.feature like '%ecf%'

