class PopulateAccountImages < ActiveRecord::DataMigration
  def up
    Account.find_each do |account|
      next if account.image_id.blank?

      begin
        image = Refile.store.get(account.image_id).download
        account.image.attach(io: image, filename: account.image_filename || 'avatar')
      rescue StandardError
        next
      end
    end
  end

  def down; end
end
