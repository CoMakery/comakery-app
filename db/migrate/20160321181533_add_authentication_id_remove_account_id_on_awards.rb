class AddAuthenticationIdRemoveAccountIdOnAwards < ActiveRecord::Migration
  def up
    add_column :awards, :authentication_id, :integer
    execute "update awards set authentication_id = auths.last_auth_id from (
               select max(authentications.id) as last_auth_id, max(awards.id) as last_award_id from awards
                 left join accounts on accounts.id = awards.account_id
                 left join authentications on accounts.id = authentications.account_id
                 group by authentications.id, awards.id) as auths
             where auths.last_award_id = awards.id"
    change_column_null :awards, :authentication_id, false
    remove_column :awards, :account_id
  end

  def down
    add_column :awards, :account_id, :integer
    execute "update awards set account_id = auths.account_id from (
               select awards.id as award_id, authentications.account_id from awards
                 left join authentications on awards.account_id = authentications.account_id) as auths
             where awards.id = award_id"
    change_column_null :awards, :account_id, false
    remove_column :awards, :authentication_id
  end
end
