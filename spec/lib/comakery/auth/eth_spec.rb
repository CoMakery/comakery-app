require 'rails_helper'

describe Comakery::Auth::Eth do
  describe 'self.random_stamp' do
    let!(:message) { 'test' }

    it 'appends random stamp to a message' do
      expect(described_class.random_stamp(message)).to match(/^#{message}#\d+\-.{12}$/)
    end
  end

  describe 'initialization' do
    let!(:nonce) { 'Authentication Request #1587583522817-09f09af12698' }
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
    let!(:valid_timestamp) { 1587583523 }
    let!(:nonce) { 'Authentication Request #1587583522817-09f09af12698' }
    let!(:signature) { '0x661c02f55ed2804d3948b36fdbed266f710074916059b0591c908ea9a30af0e542dea325acafc71ac84abfdfb44d279318286522c862dc78ff282f9bc74a3ebc1c' }
    let!(:public_address) { '0xF4258B3415Cab41Fc9cE5f9b159Ab21ede0501B1' }

    context 'with valid attributes' do
      before do
        travel_to Time.zone.at(valid_timestamp)
      end

      after do
        travel_back
      end

      it 'returns true' do
        expect(described_class.new(nonce, signature, public_address).valid?).to be_truthy
      end
    end

    context 'with invalid timestamp' do
      before do
        travel_to 100.years.from_now
      end

      after do
        travel_back
      end

      it 'returns false' do
        expect(described_class.new(nonce, signature, public_address).valid?).to be_falsey
      end
    end

    context 'with invalid signature' do
      let!(:signature) { '0x' }

      it 'returns false' do
        expect(described_class.new(nonce, signature, public_address).valid?).to be_falsey
      end
    end
  end
end
