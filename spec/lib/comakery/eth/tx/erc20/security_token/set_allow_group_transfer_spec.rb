require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::SecurityToken::SetAllowGroupTransfer, vcr: true do
  describe 'valid_method_id?' do
    context 'for security_token_set_allow_group_transfer transaction' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

      it 'returns true' do
        expect(security_token_set_allow_group_transfer.valid_method_id?).to be_truthy
      end
    end

    context 'for other transactions' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer, hash: '0x1007e9116efab368169683b81ae576bd48e168bef2be1fea5ef096ccc9e5dcc0') }

      it 'returns false' do
        expect(security_token_set_allow_group_transfer.valid_method_id?).to be_falsey
      end
    end
  end

  describe 'method_arg_0' do
    let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

    it 'returns from' do
      expect(security_token_set_allow_group_transfer.method_arg_0).to eq(0)
    end
  end

  describe 'method_arg_1' do
    let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

    it 'returns to' do
      expect(security_token_set_allow_group_transfer.method_arg_1).to eq(0)
    end
  end

  describe 'method_arg_2' do
    let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

    it 'returns lockedUntil' do
      expect(security_token_set_allow_group_transfer.method_arg_2).to eq(1586908800)
    end
  end

  describe 'valid?' do
    context 'for invalid eth transaction' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

      it 'returns false' do
        expect(security_token_set_allow_group_transfer.valid?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 2**256 - 1, 0, 0, 1586908800)).to be_falsey
      end
    end

    context 'for other erc20 transaction' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer, hash: '0x1007e9116efab368169683b81ae576bd48e168bef2be1fea5ef096ccc9e5dcc0') }

      it 'returns false' do
        expect(security_token_set_allow_group_transfer.valid?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 1, 0, 0, 1586908800)).to be_falsey
      end
    end

    context 'for security_token_set_allow_group_transfer transfer with incorrect from' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

      it 'returns false' do
        expect(security_token_set_allow_group_transfer.valid?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 1, 10, 0, 1586908800)).to be_falsey
      end
    end

    context 'for security_token_set_allow_group_transfer transaction with incorrect to' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

      it 'returns false' do
        expect(security_token_set_allow_group_transfer.valid?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 1, 0, 10, 1586908800)).to be_falsey
      end
    end

    context 'for security_token_set_allow_group_transfer transaction with incorrect lockedUntil' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

      it 'returns false' do
        expect(security_token_set_allow_group_transfer.valid?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 1, 0, 0, 1586908801)).to be_falsey
      end
    end

    context 'for correct security_token_set_allow_group_transfer' do
      let!(:security_token_set_allow_group_transfer) { build(:security_token_set_allow_group_transfer) }

      it 'returns true' do
        expect(security_token_set_allow_group_transfer.valid?('0x75f538eafdb14a2dc9f3909aa1e0ea19727ff44b', '0x1d1592c28fff3d3e71b1d29e31147846026a0a37', 1, 0, 0, 1586908800)).to be_truthy
      end
    end
  end
end
