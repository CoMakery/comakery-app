shared_examples 'having ore_id_callbacks' do
  describe '#current_ore_id_account' do
    context 'when current account doesnt have a OreIdAccount record' do
      before do
        allow_any_instance_of(described_class).to receive(:current_account).and_return(create(:account))
      end

      it 'creates a new record in :pending_manual state' do
        expect(controller.current_ore_id_account).to be_pending_manual
      end
    end
  end

  describe '#auth_url' do
    before do
      expect_any_instance_of(described_class).to receive(:current_ore_id_account).and_return(create(:ore_id))
      expect_any_instance_of(OreIdService).to receive(:authorization_url).and_return('dummy_auth_url')
    end

    it 'returns auth url' do
      expect(controller.auth_url).to be_a(String)
    end
  end

  describe '#sign_url' do
    before do
      expect_any_instance_of(described_class).to receive(:current_ore_id_account).and_return(create(:ore_id))
      expect_any_instance_of(OreIdService).to receive(:sign_url).and_return('dummy_auth_url')
    end

    it 'returns sign url' do
      expect(controller.sign_url(create(:blockchain_transaction))).to be_a(String)
    end
  end

  describe '#crypt' do
    it 'returns a ActiveSupport::MessageEncryptor' do
      expect(controller.crypt).to be_a(ActiveSupport::MessageEncryptor)
    end
  end

  describe '#state' do
    before do
      expect_any_instance_of(described_class).to receive(:current_account).and_return(create(:account))
      expect_any_instance_of(described_class).to receive(:params).and_return(ActionController::Parameters.new({ redirect_back_to: 'dummy_url' }))
      expect(controller.crypt).to receive(:encrypt_and_sign).and_return('dummy_state')
    end

    it 'returns state to be added to url' do
      expect(controller.state).to be_a(String)
    end
  end

  describe '#received_state' do
    before do
      expect_any_instance_of(described_class).to receive(:params).and_return(ActionController::Parameters.new({ state: 'dummy_state' }))
      expect(controller.crypt).to receive(:decrypt_and_verify).and_return('{"dummy": "dummy"}')
    end

    it 'returns parsed received state' do
      expect(controller.received_state).to be_a(Hash)
    end
  end

  describe '#received_error' do
    before do
      expect_any_instance_of(described_class).to receive(:params).and_return({ error_message: 'dummy_error' })
    end

    it 'returns error from received params' do
      expect(controller.received_error).to be_a(String)
    end
  end

  describe '#verify_errorless' do
    context 'when an error received' do
      before do
        allow_any_instance_of(described_class).to receive(:received_error).and_return('dummy_error')
      end

      it 'adds an error and redirects to wallets_url' do
        expect(controller).to receive(:redirect_to)
        controller.verify_errorless
        expect(controller.flash[:error]).to eq('dummy_error')
      end
    end
  end

  describe '#verify_received_account' do
    context 'when account id from received state doesnt match current account name' do
      before do
        expect_any_instance_of(described_class).to receive(:current_account).and_return(create(:account))
        expect_any_instance_of(described_class).to receive(:received_state).and_return({ account_id: 'dummy_id' })
      end

      it 'returns 401' do
        expect(controller).to receive(:head)
        controller.verify_received_account
      end
    end
  end
end
