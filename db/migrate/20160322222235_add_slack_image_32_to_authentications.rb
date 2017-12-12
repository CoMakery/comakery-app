class AddSlackImage32ToAuthentications < ActiveRecord::Migration[4.2]
  def change
    add_column :authentications, :slack_image_32_url, :string
  end
end
