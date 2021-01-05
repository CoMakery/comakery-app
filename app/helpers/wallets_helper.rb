module WalletsHelper
  def toggle_zero_balances_link
    hide_zero_balances = session[:wallets__hide_zero_balances]
    html_options = {
      type: :button,
      class: 'btn btn-link font-weight-bold',
      data: {
        action: 'wallets--page#toggleZeroBalances'
      }
    }

    link_to(wallets_path(hide_zero_balances: !hide_zero_balances), html_options) do
      if hide_zero_balances
        concat tag.i('', class: 'fas fa-eye')
        concat tag.span(' Show zero balances')
      else
        concat tag.i('', class: 'fas fa-eye-slash')
        concat tag.span(' Hide zero balances')
      end
    end
  end

  def wallet_blockchain_collection(wallet)
    wallet.available_blockchains.map { |k| [Wallet.blockchain_for(k).name, k] }
  end

  def formatted_wallet_balances(wallet)
    wallet.balances.map do |balance|
      "#{balance.value} #{balance.token.symbol}"
    end
  end
end
