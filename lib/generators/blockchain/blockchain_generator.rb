class BlockchainGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_blockchain_file
    template 'blockchain.erb', "app/models/blockchain/#{file_name}.rb"
    template 'blockchain_spec.erb', "spec/models/blockchain/#{file_name}_spec.rb"

    gsub_file(
      'app/models/blockchain.rb',
      /.+# Populated automatically by BlockchainGenerator/,
      "    #{Blockchain.append_to_list(file_name.to_sym)} # Populated automatically by BlockchainGenerator"
    )
  end
end
