class PopulateTokensImages < ActiveRecord::DataMigration
  def up
    Token.find_each do |token|
      next if token.logo_image_id.blank?

      logo_image = Refile.store.get(token.logo_image_id).download
      token.logo_image.attach(io: logo_image, filename: token.logo_image_filename)
    end
  end

  def down; end
end
