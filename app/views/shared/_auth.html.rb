class Views::Shared::Auth < Views::Projects::Base
  def content
    column('large-12 no-h-pad', style: 'margin-top: 30px') do
      h3 'Or Sign Up With'
    end

    if ENV['METAMASK_LOGIN'].present?
      column('large-12 no-h-pad', style: 'margin-top: 5px') do
        link_to '#', data: { controller: 'auth-eth', action: 'click->auth-eth#auth', target: 'auth-eth.button', 'auth-eth-nonce-path' => new_auth_eth_path, 'auth-eth-auth-path' => auth_eth_index_path, 'auth-eth-csrf-token' => form_authenticity_token }, class: 'auth-button metamask' do
          text 'MetaMask'
        end
      end
    end

    if Comakery::Slack.enabled?
      column('large-12 no-h-pad', style: 'margin-top: 10px') do
        link_to '/auth/slack', method: :post, class: 'auth-button slack' do
          text 'Slack'
        end
      end
    end

    if Comakery::Discord.enabled?
      column('large-12 no-h-pad', style: 'margin-top: 10px') do
        link_to login_discord_path, method: :post, class: 'auth-button discord' do
          text 'Discord'
        end
      end
    end

    column('large-12 no-h-pad', style: 'margin-top: 10px') do
      label do
        text 'By Signing Up  you are agreeing to the '
        link_to 'CoMakery User Agreement', '/user-agreement'
        text ' and '
        link_to 'Privacy Policy Terms', '/privacy-policy'
      end
    end
  end
end
