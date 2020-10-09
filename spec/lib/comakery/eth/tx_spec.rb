require 'rails_helper'

describe Comakery::Eth::Tx, vcr: true do
  let!(:eth_tx) { build(:eth_tx) }

  describe 'eth' do
    it 'returns Comakery::Eth' do
      expect(eth_tx.eth).to be_a(Comakery::Eth)
    end
  end

  describe 'hash' do
    it 'returns transaction hash' do
      expect(eth_tx.hash).to eq('0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d')
    end
  end

  describe 'data' do
    it 'returns transaction data' do
      expect(eth_tx.data).to be_a(Hash)
    end
  end

  describe 'receipt' do
    it 'returns transaction receipt' do
      expect(eth_tx.receipt).to be_a(Hash)
    end
  end

  describe 'block' do
    it 'returns transaction block' do
      expect(eth_tx.block).to be_a(Hash)
    end
  end

  describe 'block number' do
    it 'returns transaction block number' do
      expect(eth_tx.block_number).to eq(7121264)
    end
  end

  describe 'block time' do
    it 'returns transaction block time' do
      expect(eth_tx.block_time).to eq(Time.zone.at(1579027380))
    end
  end

  describe 'value' do
    it 'returns transaction value' do
      expect(eth_tx.value).to eq(0)
    end
  end

  describe 'from' do
    it 'returns transaction from' do
      expect(eth_tx.from).to eq('0x66ebd5cdf54743a6164b0138330f74dce436d842')
    end
  end

  describe 'to' do
    it 'returns transaction to' do
      expect(eth_tx.to).to eq('0x1d1592c28fff3d3e71b1d29e31147846026a0a37')
    end
  end

  describe 'input' do
    it 'returns transaction input' do
      expect(eth_tx.input).to eq('a9059cbb0000000000000000000000008599d17ac1cec71ca30264ddfaaca83c334f84510000000000000000000000000000000000000000000000000000000000000064')
    end
  end

  describe 'status' do
    it 'returns transaction status' do
      expect(eth_tx.status).to eq(1)
    end
  end

  describe 'confirmed?' do
    context 'for unconfirmed transaction' do
      let!(:eth_tx) { build(:eth_tx, hash: '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff') }

      it 'returns false' do
        expect(eth_tx.confirmed?).to be_falsey
      end
    end

    context 'for confirmed transaction with less than required confirmations' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns false' do
        expect(eth_tx.confirmed?(5000000)).to be_falsey
      end
    end

    context 'for confirmed transaction' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns true' do
        expect(eth_tx.confirmed?).to be_truthy
      end
    end
  end

  describe 'valid_data?' do
    context 'for transaction with failed status' do
      let!(:eth_tx) { build(:eth_tx, hash: '0x1bcda0a705a6d79935b77c8f05ab852102b1bc6aa90a508ac0c23a35d182289f') }

      it 'returns false' do
        expect(eth_tx.valid_data?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 0)).to be_falsey
      end
    end

    context 'for transaction with incorrect source' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns false' do
        expect(eth_tx.valid_data?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 0)).to be_falsey
      end
    end

    context 'for transaction with incorrect destination' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns false' do
        expect(eth_tx.valid_data?('0x66ebd5cdf54743a6164b0138330f74dce436d842', '0x66ebd5cdf54743a6164b0138330f74dce436d842', 0)).to be_falsey
      end
    end

    context 'for transaction with incorrect amount' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns false' do
        expect(eth_tx.valid_data?('0x66ebd5cdf54743a6164b0138330f74dce436d842', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 1)).to be_falsey
      end
    end

    context 'for correct transaction' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns true' do
        expect(eth_tx.valid_data?('0x66ebd5cdf54743a6164b0138330f74dce436d842', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 0)).to be_truthy
      end
    end
  end

  describe 'valid_block?' do
    context 'for transaction block mined before the supplied one' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns false' do
        expect(eth_tx.valid_block?(2**256 - 1)).to be_falsey
      end
    end

    context 'for transaction block mined after the supplied one' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns true' do
        expect(eth_tx.valid_block?(1)).to be_truthy
      end
    end
  end

  describe 'valid?' do
    context 'for transaction with incorrect data' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns false' do
        expect(eth_tx.valid?(
                 create(
                   :blockchain_transaction,
                   source: '0x66ebd5cdf54743a6164b0138330f74dce436d843',
                   destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
                   amount: 0,
                   current_block: 1
                 )
               )).to be_falsey
      end
    end

    context 'for transaction with incorrect block number' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns false' do
        expect(eth_tx.valid?(
                 create(
                   :blockchain_transaction,
                   source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
                   destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
                   amount: 100,
                   current_block: 2**256 - 1
                 )
               )).to be_falsey
      end
    end

    context 'for correct transaction' do
      let!(:eth_tx) { build(:eth_tx) }

      it 'returns true' do
        expect(eth_tx.valid?(
                 create(
                   :blockchain_transaction,
                   source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
                   destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
                   amount: 100,
                   current_block: 1
                 )
               )).to be_truthy
      end
    end
  end
end
