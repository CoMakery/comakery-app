require 'rails_helper'

describe Comakery::Eth::Tx::Erc20::SecurityToken::SetAddressPermissions, vcr: true do
  describe 'valid_method_id?' do
    context 'for security_token_set_address_permissions transaction' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns true' do
        expect(security_token_set_address_permissions.valid_method_id?).to be_truthy
      end
    end

    context 'for other transactions' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions, hash: '0x1007e9116efab368169683b81ae576bd48e168bef2be1fea5ef096ccc9e5dcc0') }

      it 'returns false' do
        expect(security_token_set_address_permissions.valid_method_id?).to be_falsey
      end
    end
  end

  describe 'method_arg_0' do
    let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

    it 'returns address' do
      expect(security_token_set_address_permissions.method_arg_0).to eq('0x8599d17ac1cec71ca30264ddfaaca83c334f8451')
    end
  end

  describe 'method_arg_1' do
    let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

    it 'returns group_id' do
      expect(security_token_set_address_permissions.method_arg_1).to eq(0)
    end
  end

  describe 'method_arg_2' do
    let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

    it 'returns time_lock_until' do
      expect(security_token_set_address_permissions.method_arg_2).to eq(86400)
    end
  end

  describe 'method_arg_3' do
    let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

    it 'returns max_balance' do
      expect(security_token_set_address_permissions.method_arg_3).to eq(100000000000000000000000000)
    end
  end

  describe 'method_arg_4' do
    let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

    it 'returns status' do
      expect(security_token_set_address_permissions.method_arg_4).to eq(false)
    end
  end

  describe 'valid?' do
    context 'for invalid eth transaction' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns false' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            2**256 - 1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            0,
            86400,
            100000000000000000000000000,
            false
          )
        ).to be_falsey
      end
    end

    context 'for other erc20 transaction' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions, hash: '0x1007e9116efab368169683b81ae576bd48e168bef2be1fea5ef096ccc9e5dcc0') }

      it 'returns false' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            0,
            86400,
            100000000000000000000000000,
            false
          )
        ).to be_falsey
      end
    end

    context 'for security_token_set_address_permissions transaction with incorrect address' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns false' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8452',
            0,
            86400,
            100000000000000000000000000,
            false
          )
        ).to be_falsey
      end
    end

    context 'for security_token_set_address_permissions transaction with incorrect group_id' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns false' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            1,
            86400,
            100000000000000000000000000,
            false
          )
        ).to be_falsey
      end
    end

    context 'for security_token_set_address_permissions transaction with incorrect time_lock_until' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns false' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            0,
            86401,
            100000000000000000000000000,
            false
          )
        ).to be_falsey
      end
    end

    context 'for security_token_set_address_permissions transaction with incorrect max_balance' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns false' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            0,
            86400,
            100000000000000000000000001,
            false
          )
        ).to be_falsey
      end
    end

    context 'for security_token_set_address_permissions transaction with incorrect status' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns false' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            0,
            86400,
            100000000000000000000000000,
            true
          )
        ).to be_falsey
      end
    end

    context 'for correct security_token_set_address_permissions transaction' do
      let!(:security_token_set_address_permissions) { build(:security_token_set_address_permissions) }

      it 'returns true' do
        expect(
          security_token_set_address_permissions.valid?(
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            '0x1d1592c28fff3d3e71b1d29e31147846026a0a37',
            1,
            '0x8599d17ac1cec71ca30264ddfaaca83c334f8451',
            0,
            86400,
            100000000000000000000000000,
            false
          )
        ).to be_truthy
      end
    end
  end
end
