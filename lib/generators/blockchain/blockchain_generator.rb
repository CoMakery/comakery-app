class BlockchainGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_blockchain_file
    template 'blockchain.erb', "app/models/blockchain/#{file_name}.rb"
  end
end
