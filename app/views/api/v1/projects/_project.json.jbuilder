json.call(
  project.decorate,
  :id,
  :title,
  :description,
  :image_url,
  :created_at,
  :updated_at
)

json.account_id project.account.managed_account_id
json.admin_ids project.admins.pluck(:managed_account_id)

json.transfer_types project.transfer_types do |t|
  json.partial! 'api/v1/transfer_types/transfer_type', transfer_type: t
end

json.token do
  json.partial! 'api/v1/tokens/token', token: project.token if project.token
end
