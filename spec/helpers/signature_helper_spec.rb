require 'rails_helper'

RSpec.describe SignatureHelper, type: :helper do
  let!(:payload) { 'test' }
  let!(:valid_signature) { CGI.escape(ActiveSupport::MessageVerifier.new(Rails.application.secrets.secret_key_base).generate(payload)) }
  let!(:invalid_signature) { '12345' }

  describe 'signature' do
    it 'returns signature for a given payload' do
      expect(helper.signature(payload)).to eq valid_signature
    end
  end

  describe 'signature_valid?' do
    it 'verifies signature for a given payload' do
      expect(helper.signature_valid?(payload, valid_signature)).to be true
      expect(helper.signature_valid?(payload, invalid_signature)).to be false
    end
  end
end
