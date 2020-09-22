# rubocop: disable Style/BlockDelimiters

require 'generator_spec'
require 'rails_helper'
require 'spec_helper'
require 'generators/token_type/token_type_generator'

describe TokenTypeGenerator, type: :generator do
  destination File.expand_path('../../tmp/generator_specs', __dir__)
  arguments %w[Dummy]

  def prepare_files
    FileUtils.mkdir_p(destination_root + '/app/models')
    File.write(destination_root + '/app/models/token_type.rb', 'h = {} # Populated automatically by TokenTypeGenerator')
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
          file 'token_type.rb' do
            contains ':dummy=>'
          end
          directory 'token_type' do
            file 'dummy.rb' do
              contains 'TokenType::Dummy'
            end
          end
        end
      end
      directory 'spec' do
        directory 'models' do
          directory 'token_type' do
            file 'dummy_spec.rb' do
              contains 'TokenType::Dummy'
            end
          end
        end
      end
    })
  end
end
