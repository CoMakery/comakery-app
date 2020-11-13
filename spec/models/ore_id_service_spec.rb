require 'rails_helper'

RSpec.describe OreIdService, type: :model, vcr: true do
  subject { described_class.new(create(:ore_id)) }

  describe '#create_remote' do
    before do
      subject.ore_id.update(account_name: nil)
    end

    specify do
      VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
        expect(subject.create_remote).to be_an(Hash)
      end
    end

    specify do
      VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
        expect { subject.create_remote }.to change(subject.ore_id, :account_name).and change(subject.ore_id, :state)
      end
    end

    context 'when remote account is already present' do
      specify do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy_errors', match_requests_on: %i[method uri]) do
          expect { subject.create_remote }.to raise_error(OreIdService::RemoteUserExistsError)
        end
      end
    end
  end

  describe '#remote' do
    before do
      subject
    end

    specify do
      VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
        expect(subject.remote).to be_an(Hash)
      end
    end

    context 'when remote account is unknown' do
      before do
        subject.ore_id.update(account_name: nil)
      end

      specify do
        expect { subject.remote }.to raise_error(OreIdService::RemoteInvalidError)
      end
    end

    context 'when remote service returns an error' do
      specify do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy_errors', match_requests_on: %i[method uri]) do
          expect { subject.remote }.to raise_error(OreIdService::Error)
        end
      end
    end
  end

  describe '#permissions' do
    before do
      subject
    end

    it 'returns Array of permisssions assigned to local blockchains' do
      VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
        permissions = subject.permissions

        expect(permissions).to be_an(Array)
        expect(permissions.first[:_blockchain]).not_to be_nil
        expect(permissions.first[:address]).not_to be_nil
      end
    end

    context 'when remote permissions are not present' do
      specify do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy_permissions_missing', match_requests_on: %i[method uri]) do
          expect { subject.permissions }.to raise_error(OreIdService::RemoteInvalidError)
        end
      end
    end
  end

  describe '#create_token' do
    specify do
      VCR.use_cassette('ore_id_service/token', match_requests_on: %i[method uri]) do
        expect(subject.create_token).to be_an(String)
      end
    end
  end

  describe '#authorization_url' do
    before do
      expect(subject).to receive(:create_token).and_return('test')
    end

    specify do
      expect(subject.authorization_url('localhost', 'dummystate')).to eq('https://service.oreid.io/auth?app_access_token=test&background_color=FFFFFF&callback_url=localhost&provider=email&state=dummystate')
    end
  end

  describe '#sign_url' do
    before do
      expect(subject).to receive(:create_token).and_return('test')
      expect(subject).to receive(:algo_transfer_transaction).and_return({})
    end

    specify do
      expect(
        subject.sign_url(transaction: create(:blockchain_transaction), callback_url: 'localhost', state: 'dummystate')
      ).to eq('https://service.oreid.io/sign?account=ore1ryuzfqwy&app_access_token=test&broadcast=true&callback_url=localhost&chain_account=0x42D00fC2Efdace4859187DE4865Df9BaA320D5dB&chain_network=&return_signed_transaction=true&state=dummystate&transaction=e30%3D%0A')
    end
  end
end
