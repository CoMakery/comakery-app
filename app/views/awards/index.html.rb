class Views::Awards::Index < Views::Base
  needs :project, :awards

  def content # rubocop:todo Metrics/PerceivedComplexity
    render partial: 'shared/project_header'
    full_row do
      render partial: 'awards/activity'
    end
    pages
    if current_account
      full_row do
        div(class: 'small-1', style: 'float: left') do
          label do
            checked = !(params[:mine] == 'true')
            radio_button_tag 'mine', url_for, checked, class: 'toggle-radio'
            text 'all'
          end
        end
        div(class: 'small-1', style: 'float: left') do
          label do
            checked = params[:mine] == 'true'
            radio_button_tag 'mine', url_for(mine: true), checked, class: 'toggle-radio'
            text 'mine'
          end
        end
      end
    end
    render partial: 'shared/awards',
           locals: { project: project, awards: awards, show_recipient: true }
    pages
    javascript_include_tag Webpacker.manifest.lookup!('wallets/qrc20_qweb3_script.js') if project.token&.coin_type_qrc20?
    javascript_include_tag Webpacker.manifest.lookup!('wallets/cardano_trezor_script.js') if project.token&.coin_type_ada?
    javascript_include_tag Webpacker.manifest.lookup!('wallets/bitcoin_trezor_script.js') if project.token&.coin_type_btc?
    javascript_include_tag Webpacker.manifest.lookup!('wallets/qtum_ledger_script.js') if project.token&.coin_type_qtum?
    javascript_include_tag Webpacker.manifest.lookup!('wallets/eos_scatter_script.js') if project.token&.coin_type_eos?
    javascript_include_tag 'eztz.min' if project.token&.coin_type_xtz?
    javascript_include_tag '//connect.trezor.io/6/trezor-connect.js' if project.token&.coin_type_xtz?
    javascript_include_tag Webpacker.manifest.lookup!('wallets/tezos_trezor_script.js') if project.token&.coin_type_xtz?
  end

  def pages
    full_row do
      div(class: 'callout clearfix') do
        div(class: 'pagination float-right') do
          text paginate project.awards.page(params[:page])
        end
      end
    end
  end
end
