class CreateApiRequestLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :api_request_logs do |t|
      t.inet :ip, null: false
      t.string :signature, null: false
      t.jsonb :body, null: false
      t.datetime :created_at, index: true, null: false
    end

    add_index :api_request_logs, :signature, unique: true
  end
end
