require 'rails_helper'

RSpec.describe OreIdService, type: :model, vcr: true do
  subject { described_class.new(create(:ore_id, skip_jobs: true)) }

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

  describe '#create_tx' do
    let(:tx) do
      create(
        :blockchain_transaction,
        amount: 1,
        source: build(:algorand_address_1),
        destination: build(:algorand_address_2),
        token: create(:algorand_token),
        network: :algorand_test
      )
    end

    before do
      subject
    end

    specify do
      VCR.use_cassette('ore_id_service/new_tx', match_requests_on: %i[method uri]) do
        expect { subject.create_tx(tx) }.to change(tx, :tx_hash).and change(tx, :tx_raw).and change(tx, :status)
      end
    end

    context 'when remote account is unknown' do
      before do
        subject.ore_id.update(account_name: nil)
      end

      specify do
        expect { subject.create_tx(tx) }.to raise_error(OreIdService::RemoteInvalidError)
      end
    end

    context 'when ore_id is not pending' do
      before do
        subject.ore_id.update(state: :pending_manual)
      end

      specify do
        expect { subject.create_tx(tx) }.to raise_error(OreIdService::RemoteInvalidError)
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

  describe '#password_updated?' do
    before do
      subject
    end

    context 'when remote password has been updated' do
      specify do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy_password_updated', match_requests_on: %i[method uri]) do
          expect(subject.password_updated?).to be_truthy
        end
      end
    end

    context 'when remote password has been updated' do
      specify do
        VCR.use_cassette('ore_id_service/ore1ryuzfqwy', match_requests_on: %i[method uri]) do
          expect(subject.password_updated?).to be_falsey
        end
      end
    end

    context 'when remote is not present' do
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
      url = 'https://service.oreid.io/auth?app_access_token=test&background_color=FFFFFF&callback_url=localhost&provider=email&state=dummystate'
      hmac = build(:ore_id_hmac, url)
      expect(subject.authorization_url('localhost', 'dummystate')).to eq("#{url}&hmac=#{hmac}")
    end
  end

  describe '#sign_url' do
    before do
      expect(subject).to receive(:create_token).and_return('test')
    end

    context 'with Algo token' do
      let(:transaction) do
        create(
          :blockchain_transaction,
          token: create(:algorand_token),
          source: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
        )
      end

      specify do
        generated_url = subject.sign_url(transaction: transaction, callback_url: 'localhost', state: 'dummystate')
        expected_url = 'https://service.oreid.io/sign?account=ore1ryuzfqwy&app_access_token=test&broadcast=true&callback_url=localhost&chain_account=YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA&chain_network=algo_test&return_signed_transaction=true&state=dummystate&transaction=eyJmcm9tIjoiWUY2RkFMU1hJNEJSVUZYQkZIWVZDT0tGUk9BV0JRWjQyWTRC%0AWFVLN1NESFRXN0IyN1RFUUIzQUhTQSIsInRvIjoiRTNJVDJURFdFSlM1NVhD%0ASTVOT0IySE9ONlhVQklaNlNEVDJUQUhUS0RRTUtSNEFIRVFDUk9PWEZJRSIs%0AImFtb3VudCI6MSwidHlwZSI6InBheSJ9%0A'
        hmac = build(:ore_id_hmac, expected_url)
        expect(generated_url).to eq("#{expected_url}&hmac=#{hmac}")
      end
    end

    context 'with ASA token' do
      let(:transaction) do
        create(
          :blockchain_transaction,
          token: create(:asa_token),
          source: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
        )
      end

      specify do
        generated_url = subject.sign_url(transaction: transaction, callback_url: 'localhost', state: 'dummystate')
        expected_url = 'https://service.oreid.io/sign?account=ore1ryuzfqwy&app_access_token=test&broadcast=true&callback_url=localhost&chain_account=YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA&chain_network=algo_test&return_signed_transaction=true&state=dummystate&transaction=eyJmcm9tIjoiWUY2RkFMU1hJNEJSVUZYQkZIWVZDT0tGUk9BV0JRWjQyWTRC%0AWFVLN1NESFRXN0IyN1RFUUIzQUhTQSIsInRvIjoiRTNJVDJURFdFSlM1NVhD%0ASTVOT0IySE9ONlhVQklaNlNEVDJUQUhUS0RRTUtSNEFIRVFDUk9PWEZJRSIs%0AImFtb3VudCI6MSwidHlwZSI6ImF4ZmVyIiwiYXNzZXRJbmRleCI6MTMwNzYz%0ANjd9%0A'
        hmac = build(:ore_id_hmac, expected_url)
        expect(generated_url).to eq("#{expected_url}&hmac=#{hmac}")
      end
    end
  end

  describe '#algorand_transaction' do
    context 'with ALGO token' do
      let(:transaction) do
        create(
          :blockchain_transaction,
          token: create(:algorand_token),
          source: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
        )
      end

      specify do
        expect(subject.send(:algorand_transaction, transaction)).to eq(
          amount: 1,
          from: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          to: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE',
          type: 'pay'
        )
      end
    end

    context 'with ASA token' do
      let(:transaction) do
        create(
          :blockchain_transaction,
          token: create(:asa_token),
          source: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
        )
      end

      specify do
        expect(subject.send(:algorand_transaction, transaction)).to eq(
          amount: 1,
          from: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          to: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE',
          type: 'axfer',
          assetIndex: 13076367
        )
      end
    end

    context 'with Algorand Security token' do
      let(:transaction) do
        create(
          :blockchain_transaction,
          token: create(:algo_sec_token),
          source: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
        )
      end

      specify do
        expect(subject.send(:algorand_transaction, transaction)).to eq(
          amount: nil,
          from: 'YF6FALSXI4BRUFXBFHYVCOKFROAWBQZ42Y4BXUK7SDHTW7B27TEQB3AHSA',
          to: nil,
          type: 'appl',
          appIndex: 13258116,
          appOnComplete: 1
        )
      end
    end
  end
end
