class AddAgreedToUserAgreementToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :agreed_to_user_agreement, :date
  end
end
