class ChangeAddressNullForWallet < ActiveRecord::Migration[6.0]
  def change
    change_column_null :wallets, :address, true
  end
end
