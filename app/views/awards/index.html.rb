class Views::Awards::Index < Views::Base
  needs :project, :awards

  def content
    render partial: 'shared/project_header'
    full_row do
      render partial: 'awards/activity'
    end
    pages
    if current_account
      full_row do
        div(class: 'small-1', style: 'float: left') do
          label do
            checked = params[:mine] == 'true' ? false : true
            radio_button_tag 'mine', url_for, checked, class: 'toggle-radio'
            text 'all'
          end
        end
        div(class: 'small-1', style: 'float: left') do
          label do
            checked = params[:mine] == 'true' ? true : false
            radio_button_tag 'mine', url_for(mine: true), checked, class: 'toggle-radio'
            text 'mine'
          end
        end
      end
    end
    render partial: 'shared/awards',
           locals: { project: project, awards: awards, show_recipient: true }
    pages
    render 'sessions/metamask_modal' if current_account&.decorate&.can_send_awards?(project)
    javascript_include_tag 'https://connect.trezor.io/6/trezor-connect.js' if project.use_trezor?
    javascript_include_tag Webpacker.manifest.lookup!('qtum_script.js') if project.coin_type_on_qtum?
    javascript_include_tag Webpacker.manifest.lookup!('cardano_script.js') if project.coin_type_on_cardano?
    javascript_include_tag Webpacker.manifest.lookup!('wallets/bitcoin_trezor_script.js') if project.coin_type_on_bitcoin?
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
