require 'csv'

class TransfersExporter
  def initialize(project)
    @project = project
  end

  # rubocop:todo Metrics/PerceivedComplexity
  def project_transfers_csv_data # rubocop:todo Metrics/CyclomaticComplexity
    if @project.token&.symbol
      amount_col = "Amount(#{@project.token.symbol})"
      total_col = "Total(#{@project.token.symbol})"
    else
      amount_col = 'Amount'
      total_col = 'Total'
    end

    column_names = ['Recipient User ID', 'Recipient First Name', 'Recipient Last Name', 'Recipient blockchain adddress', 'Sender First Name', 'Sender Last Name', 'Sender blockchain adddress', 'Transfer Name', 'Transfer Type', 'Account', 'Transfered By', amount_col, 'Quantity', total_col, 'Transaction', 'Transaction ID', 'Transfered', 'Created At'].freeze

    CSV.generate({ force_quotes: true, col_sep: ',' }) do |csv|
      csv << column_names
      @project.awards.completed.includes(:award_type, :issuer, project: [:token]).order('created_at desc').decorate.each do |transfer|
        transfer_transaction = if @project.token && @project.token&._token_type?
          if transfer.paid? && transfer.ethereum_transaction_explorer_url
            transfer.ethereum_transaction_address_short
          elsif transfer.project.token&.token_frozen?
            'frozen'
          elsif transfer.recipient_address.blank?
            'needs wallet'
          else
            'pending'
          end
        else
          '-'
        end

        account = transfer.account
        issuer = transfer.issuer

        csv << [transfer.account_id,
                account.first_name,
                account.last_name,
                transfer.recipient_address,
                issuer.first_name,
                issuer.last_name,
                transfer.issuer_address,
                transfer.name,
                transfer.transfer_type&.name,
                account ? account.decorate.name : transfer.email,
                transfer.paid? ? transfer.issuer.decorate.name : '–',
                transfer.amount_pretty,
                transfer.quantity,
                transfer.total_amount_pretty,
                transfer_transaction,
                transfer.ethereum_transaction_id,
                transfer.paid? && transfer.transferred_at ? transfer.transferred_at.strftime('%b %e %Y') : '–',
                transfer.created_at.strftime('%b %e %Y')]
      end
    end
  end
end
