json.cache! @accounts do
  json.array! @accounts.map do |account|
    json.cache! account do
      account = account.decorate

      json.id account.id
      json.value account.id
      json.label account.name
      json.custom_properties account.avatar_tag
    end
  end
end
