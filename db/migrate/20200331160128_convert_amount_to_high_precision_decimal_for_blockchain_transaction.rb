class ConvertAmountToHighPrecisionDecimalForBlockchainTransaction < ActiveRecord::Migration[6.0]
  def change
    change_column :blockchain_transactions, :amount, :decimal, precision: 78, scale: 0
  end
end
