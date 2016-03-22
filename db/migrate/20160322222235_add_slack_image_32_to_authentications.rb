class AddSlackImage32ToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :slack_image_32_url, :string
  end
end
