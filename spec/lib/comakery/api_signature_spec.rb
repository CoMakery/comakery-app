require 'rails_helper'

describe Comakery::APISignature do
  let(:private_key) { 'eodjQfDLTyNCBnz+MORHW0lOKWZnCTyPDTFcwAdVRyQ7vNMfjEecPWNEqF4FOuk03bgWDV10vwMcqL/OBUJWkA==' }
  let(:public_key) { 'O7zTH4xHnD1jRKheBTrpNN24Fg1ddL8DHKi/zgVCVpA=' }
  let(:stubbed_time) { 1579619468 }
  let(:stubbed_nonce) { '7a8e8481d2c99e6fac9a1a21b181f4b6' }
  let(:stubbed_sign) { 'WVsm4LkQIXurcPeFkhI3RWcgHWecys5vTA/RP5S+2bSyvs1g60FQfMr220dwoss0dUM5hFvJha9U3Gt3tGkRAg==' }
  let(:stubbed_url) { 'https://example.org/' }
  let(:stubbed_method) { 'GET' }

  let(:valid_unsigned_request) do
    {
      'body' => {
        'data' => {},
        'url' => stubbed_url,
        'method' => stubbed_method
      }
    }
  end

  let(:valid_signed_request) do
    {
      'body' => {
        'data' => {},
        'url' => stubbed_url,
        'method' => stubbed_method,
        'nonce' => stubbed_nonce,
        'timestamp' => stubbed_time.to_s
      },
      'proof' => {
        'type' => 'Ed25519Signature2018',
        'verificationMethod' => public_key,
        'signature' => stubbed_sign
      }
    }
  end

  before do
    allow(Time).to receive(:now).and_return(Time.at(stubbed_time).utc)
    allow(SecureRandom).to receive(:hex).and_return(stubbed_nonce)
  end

  describe 'sign' do
    let(:signed_request) { described_class.new(valid_unsigned_request).sign(private_key) }

    it 'appends nonce' do
      expect(signed_request['body']['nonce']).to eq(stubbed_nonce)
    end

    it 'appends timestamp' do
      expect(signed_request['body']['timestamp']).to eq(stubbed_time.to_s)
    end

    it 'creates proof with correct signature' do
      expect(signed_request['proof']['type']).to eq('Ed25519Signature2018')
      expect(signed_request['proof']['verificationMethod']).to eq(public_key)
      expect(signed_request['proof']['signature']).to eq(stubbed_sign)
    end
  end

  describe 'verify' do
    context 'with invalid http url' do
      it 'raises according exception' do
        expect do
          described_class.new(valid_signed_request, '/test', stubbed_method).verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid URL')
      end
    end

    context 'with invalid http method' do
      it 'raises according exception' do
        expect do
          described_class.new(valid_signed_request, stubbed_url, 'POST').verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid HTTP method')
      end
    end

    context 'with invalid type' do
      it 'raises according exception' do
        valid_signed_request['proof']['type'] = '?'

        expect do
          described_class.new(valid_signed_request, stubbed_url, stubbed_method).verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid proof type')
      end
    end

    context 'with invalid timestamp' do
      it 'raises according exception' do
        valid_signed_request['body']['timestamp'] = 100.years.ago.to_i

        expect do
          described_class.new(valid_signed_request, stubbed_url, stubbed_method).verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid timestamp')
      end
    end

    context 'with invalid nonce' do
      it 'raises according exception' do
        is_nonce_unique = ->(_) { false }

        expect do
          described_class.new(valid_signed_request, stubbed_url, stubbed_method, is_nonce_unique).verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid nonce')
      end
    end

    context 'with invalid proof method' do
      it 'raises according exception' do
        valid_signed_request['proof']['verificationMethod'] = 'Hello'

        expect do
          described_class.new(valid_signed_request, stubbed_url, stubbed_method).verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid proof verificationMethod')
      end
    end

    context 'with invalid proof signature' do
      it 'raises according exception' do
        valid_signed_request['proof']['signature'] = 'signature'

        expect do
          described_class.new(valid_signed_request, stubbed_url, stubbed_method).verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid proof signature')
      end
    end

    context 'with too long nonce' do
      let(:stubbed_nonce) { 'a' * 50 }

      it 'cut it to MAX_NONCE_SIZE' do
        is_nonce_unique = lambda do |nonce|
          expect(nonce.size).to eq Comakery::APISignature::MAX_NONCE_SIZE
          true
        end

        expect do
          described_class.new(valid_signed_request, stubbed_url, stubbed_method, is_nonce_unique).verify(public_key)
        end.to raise_error(Comakery::APISignatureError, 'Invalid proof signature')
      end
    end

    context 'with valid request' do
      it 'returns true' do
        expect(described_class.new(valid_signed_request, stubbed_url, stubbed_method).verify(public_key)).to be_truthy
      end
    end
  end
end
