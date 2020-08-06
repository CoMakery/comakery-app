class AddTransferTypeToAwards < ActiveRecord::Migration[6.0]
  def change
    add_reference :awards, :transfer_type, foreign_key: true
  end
end
