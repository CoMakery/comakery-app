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
        expect { subject.create_remote }.to change(subject.ore_id, :account_name)
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
end
