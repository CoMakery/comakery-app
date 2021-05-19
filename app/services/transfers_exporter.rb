require 'csv'

class TransfersExporter
  def initialize(project)
    @project = project
  end

  def transfers_csv_columns
    if @project.token&.symbol
      amount_col = "Amount(#{@project.token.symbol})"
      total_col = "Total(#{@project.token.symbol})"
    else
      amount_col = 'Amount'
      total_col = 'Total'
    end
    ['Recipient User ID', 'Recipient First Name', 'Recipient Last Name', 'Recipient blockchain adddress', 'Sender First Name', 'Sender Last Name', 'Sender blockchain adddress', 'Transfer Name', 'Transfer Type', amount_col, 'Quantity', total_col, 'Transaction ID', 'Transfered', 'Created At']
  end

  def transfers_csv_row(decorate)
    [decorate.account_id, decorate.recipient_first_name, decorate.recipient_last_name,
     decorate.recipient_address, decorate.issuer_first_name, decorate.issuer_last_name,
     decorate.issuer_address, decorate.name, decorate.transfer_type_name, decorate.amount_pretty,
     decorate.quantity, decorate.total_amount_pretty, decorate.transfer_transaction,
     decorate.transfered_date, decorate.created_date]
  end

  def generate_transfers_csv
    CSV.generate({ force_quotes: true, col_sep: ',' }) do |csv|
      csv << transfers_csv_columns
      @project.awards.completed.includes(:award_type, :issuer, project: [:token]).order('created_at desc').find_each do |transfer|
        decorate = transfer.decorate
        csv << transfers_csv_row(decorate)
      end
    end
  end
end
