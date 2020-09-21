# rubocop: disable Style/BlockDelimiters

require 'generator_spec'
require 'rails_helper'
require 'spec_helper'
require 'generators/blockchain/blockchain_generator'

describe BlockchainGenerator, type: :generator do
  destination File.expand_path('../../tmp/generator_specs', __dir__)
  arguments %w[Dummy]

  def prepare_files
    FileUtils.mkdir_p(destination_root + '/app/models')
    File.write(destination_root + '/app/models/blockchain.rb', 'h = {} # Populated automatically by BlockchainGenerator')
  end

  before do
    prepare_destination
    prepare_files
    run_generator
  end

  specify do
    expect(destination_root).to(have_structure {
      directory 'app' do
        directory 'models' do
          file 'blockchain.rb' do
            contains ':dummy=>'
          end
          directory 'blockchain' do
            file 'dummy.rb' do
              contains 'Blockchain::Dummy'
            end
          end
        end
      end
      directory 'spec' do
        directory 'models' do
          directory 'blockchain' do
            file 'dummy_spec.rb' do
              contains 'Blockchain::Dummy'
            end
          end
        end
      end
    })
  end
end
