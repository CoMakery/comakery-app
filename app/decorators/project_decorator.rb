class ProjectDecorator < Draper::Decorator
  delegate_all

  def description_html
    Comakery::Markdown.to_html(object.description)
  end

  def description_text
    Comakery::Markdown.to_text(object.description).truncate(90)
  end

  def ethereum_contract_explorer_url
    if ethereum_contract_address
      "https://#{Rails.application.config.ethercamp_subdomain}.ether.camp/account/#{project.ethereum_contract_address}"
    else
      nil
    end
  end
end
