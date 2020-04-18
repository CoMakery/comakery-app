require 'rails_helper'

describe Comakery::Auth::Eth do
  describe 'self.random_stamp' do
    let!(:message) { 'test' }

    it 'appends random stamp to a message' do
      expect(described_class.random_stamp(message)).to match(/#{message}#\d{12}\-\d+/)
    end
  end

  describe 'initialization' do
    let!(:nonce) { 'nonce' }
    let!(:signature) { 'signature' }
    let!(:public_address) { 'nonce' }
    let!(:auth) { described_class.new(nonce, signature, public_address) }

    it 'sets attributes' do
      expect(auth.nonce).to eq(nonce)
      expect(auth.signature).to eq(signature)
      expect(auth.public_address).to eq(public_address)
    end
  end

  describe 'valid?' do
    context 'with valid attributes' do
      let!(:nonce) { 'test' }
      let!(:signature) { '0x62949f93af21d260a9794ef97a4d6c099b8fe65d391604cc86555ded69c21a5b39bcb6ca672d11b55254c594c8921d6293b0a639510e6ee61177ddfa1490a9291b' }
      let!(:public_address) { '0xF4258B3415Cab41Fc9cE5f9b159Ab21ede0501B1' }

      it 'returns true' do
        expect(described_class.new(nonce, signature, public_address).valid?).to be_truthy
      end
    end

    context 'with invalid attributes' do
      let!(:nonce) { 'invalid' }
      let!(:signature) { '0x62949f93af21d260a9794ef97a4d6c099b8fe65d391604cc86555ded69c21a5b39bcb6ca672d11b55254c594c8921d6293b0a639510e6ee61177ddfa1490a9291b' }
      let!(:public_address) { '0xF4258B3415Cab41Fc9cE5f9b159Ab21ede0501B1' }

      it 'returns false' do
        expect(described_class.new(nonce, signature, public_address).valid?).to be_falsey
      end
    end
  end
end
