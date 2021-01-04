class PopulateAccountImages < ActiveRecord::DataMigration
  def up
    Account.find_each do |account|
      next if account.image_id.blank?

      image = Refile.store.get(account.image_id).download
      account.image.attach(io: image, filename: account.image_filename)
    end
  end

  def down; end
end
