require 'rails_helper'
require 'models/token_type_spec'

describe TokenType::Eos do
  it_behaves_like 'a token type'
end
