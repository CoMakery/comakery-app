class TokenTypeGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  def create_token_type_file
    template 'token_type.erb', "app/models/token_type/#{file_name}.rb"
    template 'token_type_spec.erb', "spec/models/token_type/#{file_name}_spec.rb"
  end
end
