module ApplicationHelper
  def account_image_url(account, size)
    attachment_url(account, :image, :fill, size, size, fallback: 'default_account_image.jpg')
  end

  def project_image_url(obj, size)
    attachment_url(obj, :square_image, :fill, size, size, fallback: 'defaul_project.jpg')
  end

  def project_page
    if controller_name == 'projects'
      params[:action]
    else
      controller_name
    end
  end

  def ransack_filter_present?(query, name, predicate, value) # rubocop:todo Metrics/CyclomaticComplexity
    query.conditions.any? do |c|
      return false unless c.predicate.name == predicate
      return false unless c.attributes.any? { |a| a.name == name }
      return false unless c.values.any? { |v| v.value == value }

      true
    end
  end

  def enabled_auth_labels
    options = []
    options << 'Slack' if Comakery::Slack.enabled?
    options << 'Metamask'
    options << 'Discord' if Comakery::Discord.enabled?
    last = options.pop
    [options.join(', '), last].join(' or ')
  end
end
