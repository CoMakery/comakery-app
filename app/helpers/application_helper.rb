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

  def ethereum_explorer_domain(token)
    case token&.ethereum_network
    when nil
      Rails.application.config.ethereum_explorer_site
    when 'main'
      'etherscan.io'
    else
      "#{token.ethereum_network}.etherscan.io"
    end
  end

  def ethereum_explorer_tx_url(token, tx) # rubocop:todo Naming/MethodParameterName
    "https://#{ethereum_explorer_domain(token)}/tx/#{tx}"
  end

  def ransack_filter_present?(query, name, predicate, value) # rubocop:todo Metrics/CyclomaticComplexity
    query.conditions.any? do |c|
      return false unless c.predicate.name == predicate
      return false unless c.attributes.any? { |a| a.name == name }
      return false unless c.values.any? { |v| v.value == value }

      true
    end
  end
end
