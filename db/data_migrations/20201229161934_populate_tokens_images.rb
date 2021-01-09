class PopulateTokensImages < ActiveRecord::DataMigration
  def up
    Token.find_each do |token|
      next if token.logo_image_id.blank?

      begin
        logo_image = Refile.store.get(token.logo_image_id).download
        token.logo_image.attach(
          io: logo_image,
          filename: token.logo_image_filename || 'token_image'
        )
      rescue StandardError
        next
      end
    end
  end

  def down; end
end
