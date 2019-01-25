class AddTokenReferenceToProject < ActiveRecord::Migration[5.1]
  def change
    add_reference :projects, :token, foreign_key: true, index: true
  end
end
