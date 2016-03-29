class SlackAuthHash
  class MissingAuthParamException < Exception; end

  def initialize(auth_hash)
    @auth_hash = auth_hash.to_h
    unless provider && email_address && slack_team_id && slack_team_name && slack_team_image_34_url && slack_team_image_132_url && slack_user_id && slack_user_name && slack_token
      attrs = { provider: provider,
                email_address: email_address,
                slack_team_id: slack_team_id,
                slack_team_name: slack_team_name,
                slack_team_image_34_url: slack_team_image_34_url,
                slack_team_image_132_url: slack_team_image_132_url,
                slack_user_id: slack_user_id,
                slack_user_name: slack_user_name,
                slack_token: slack_token }
      message = "Slack auth hash is missing one or more required values:\n" \
        "#{JSON.pretty_generate attrs, indent: '    '}"
      raise MissingAuthParamException.new(message)
    end
  end

  def provider
    @provider ||= @auth_hash['provider']
  end

  def slack_user_id
    @slack_user_id ||= @auth_hash.dig('info', 'user_id')
  end

  def slack_user_name
    @slack_user_name ||= @auth_hash.dig('info', 'user').presence || @auth_hash.dig('extra', 'user_info', 'name').presence || @auth_hash.dig('extra', 'raw_info', 'user')
  end

  def slack_first_name
    @slack_first_name ||= @auth_hash.dig('info', 'first_name').presence
  end

  def slack_last_name
    @slack_last_name ||= @auth_hash.dig('info', 'last_name').presence
  end

  def slack_real_name
    @slack_real_name ||= @auth_hash.dig('extra', 'user_info', 'user', 'real_name')
  end

  def slack_team_id
    @slack_team_id ||= @auth_hash.dig('info', 'team_id')
  end

  def slack_team_name
    @slack_team_name ||= @auth_hash.dig('info', 'team')
  end

  def slack_image_32_url
    @slack_image_32_url ||= @auth_hash.dig('extra', 'user_info', 'user', 'profile', 'image_32')
  end

  def slack_team_image_34_url
    @slack_team_image_34_url ||= @auth_hash.dig('extra', 'team_info', 'team', 'icon', 'image_34')
  end

  def slack_team_image_132_url
    @slack_team_image_132_url ||= @auth_hash.dig('extra', 'team_info', 'team', 'icon', 'image_132')
  end

  def slack_token
    @slack_token ||= @auth_hash.dig('credentials', 'token')
  end

  def slack_team_domain
    @slack_team_domain ||= @auth_hash.dig('info', 'team_domain')
  end

  def email_address
    @email_address ||= @auth_hash.dig('info', 'email').presence || @auth_hash.dig('extra', 'user_info', 'user', 'profile', 'email')
  end
end
