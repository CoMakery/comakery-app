class AddProjectIdToWallet < ActiveRecord::Migration[6.0]
  def change
    add_reference :wallets, :project, index: true, foreign_key: true
  end
end
