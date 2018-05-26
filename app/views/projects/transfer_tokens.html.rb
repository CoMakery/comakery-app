class Views::Projects::TransferTokens < Views::Projects::Base
  needs :project

  def content
    full_row { h4 "Transfer tokens (contract address: #{project.ethereum_contract_address})" }
    form_for project, html: { class: 'transfer-tokens-form' } do |f|
      f.hidden_field :ethereum_contract_address
      row {
        label {
          text 'Receiver Address'
          text_field_tag :receiver_address
        }
        label {
          text 'Amount'
          text_field_tag :amount
        }
        link_to 'Transfer tokens', 'javascript:void(0)', class: 'button transfer-tokens-btn'
      }
    end
    render 'sessions/metamask_modal'
  end

end
