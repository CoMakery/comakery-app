class AddBatchContractAddressToTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :tokens, :batch_contract_address, :string
  end
end
