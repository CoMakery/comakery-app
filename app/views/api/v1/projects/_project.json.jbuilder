json.call(
  project.decorate,
  :id,
  :title,
  :description,
  :image_url,
  :account_id,
  :created_at,
  :updated_at
)

json.admin_ids project.admins.pluck(:id)

json.token do
  json.partial! 'api/v1/tokens/token', token: project.token if project.token
end
