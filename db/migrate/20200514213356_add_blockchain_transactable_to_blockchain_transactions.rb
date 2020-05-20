class AddBlockchainTransactableToBlockchainTransactions < ActiveRecord::Migration[6.0]
  def change
    add_reference :blockchain_transactions, :blockchain_transactable, polymorphic: true, index: { name: "index_bc_txs_on_bc_txble_type_and_bc_txble_id" }
  end
end
