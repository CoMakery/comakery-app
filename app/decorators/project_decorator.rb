class ProjectDecorator < Draper::Decorator
  delegate_all

  def description
    Comakery::Markdown.to_html(object.description)
  end

  def ethereum_contract_explorer_url
    if ethereum_contract_address
      "https://#{Rails.application.config.ethercamp_subdomain}.ether.camp/account/#{project.ethereum_contract_address}"
    else
      nil
    end
  end
end
