require 'rails_helper'

describe 'transfer button on Transfers page' do
  let!(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }
  let!(:project) { transfer.project }
  let!(:ore_id) { create(:ore_id, account: project.account, skip_jobs: true) }
  let!(:account) { project.account }

  before do
    project.update!(visibility: :public_listed)
  end

  subject { visit project_dashboard_transfers_path(project) }

  context 'when project owner or admin' do
    before do
      transfer.ready!
      project.create_hot_wallet!(address: build(:bitcoin_address_1), name: 'test name', account: project.account)

      account.update!(password: 'password')
      visit new_session_path

      fill_in 'email', with: account.email
      fill_in 'password', with: 'password'

      find("input[type='submit']").click
      subject
    end

    it 'shows only hot wallet link' do
      expect(page).to have_css("#project_#{project.id}_hot_wallet_mode")
    end
  end

  context 'when hot wallet present' do
    before do
      transfer.ready!
      project.create_hot_wallet!(address: build(:bitcoin_address_1), name: 'test name', account: project.account)
      subject
    end

    it 'shows how wallet link and edit mode' do
      expect(page).to have_css('.hot-wallet-address')
    end
  end

  context 'no hot wallet' do
    before do
      transfer.ready!
      subject
    end

    it 'does not show hot wallet' do
      expect(page).not_to have_css("#project_#{project.id}_hot_wallet_mode")
      expect(page).not_to have_css('.hot-wallet-address')
    end
  end

  context 'without a token' do
    before do
      transfer.ready!
      project.update!(token: nil)
      subject
    end

    it 'is not present' do
      expect(page).not_to have_css('.transfers-table__transfer__status .transfer-button')
    end
  end

  context 'when transfer is cancelled' do
    before do
      transfer.cancelled!
      subject
    end

    it 'is not present' do
      expect(page).not_to have_css('.transfers-table__transfer__status .transfer-button')
    end
  end

  context 'with a token supported by OREID' do
    context 'when transfer is paid' do
      before do
        transfer.paid!
        create(
          :blockchain_transaction,
          blockchain_transactable: transfer,
          token: transfer.token,
          amount: 1,
          tx_hash: 'MNGGXTRI4XE6LQJQ3AW3PBBGD5QQFRXMRSXZFUMHTKJKFEQ6TZ2A',
          source: 'YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4',
          destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
        )
        subject
      end

      it 'links to blockchain transaction' do
        expect(page).to have_css('.transfers-table__transfer__status .transfer-button a', count: 1)
      end
    end

    context 'when transfer is accepted' do
      before do
        transfer.accepted!
      end

      context 'and token is frozen' do
        before do
          project.token.update!(token_frozen: true)
          subject
        end

        it 'says frozen' do
          expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'frozen')
        end
      end

      context 'and logged in as project admin' do
        before do
          login(project.account)
        end

        context 'and recepient does not have a wallet' do
          before do
            allow_any_instance_of(Award).to receive(:recipient_address).and_return(nil)
            subject
          end

          it 'says needs wallet' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'needs wallet')
          end
        end

        context 'and admin does not have OREID linked' do
          before do
            project.account.update!(ore_id_account: nil)
            subject
          end

          it 'links to Wallets' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'link OREID')
          end
        end

        context 'and admin has OREID linked' do
          before do
            subject
          end

          it 'links to OREID' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'PAY')
          end
        end
      end

      context 'and logged in as transfer recepient' do
        before do
          login(transfer.account)
        end

        context 'and recepient does not have a wallet' do
          before do
            allow_any_instance_of(Award).to receive(:recipient_address).and_return(nil)
            subject
          end

          it 'links to Wallets' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button a', count: 1, text: 'set wallet')
          end
        end

        context 'and admin does not have OREID linked' do
          before do
            project.account.update!(ore_id_account: nil)
            subject
          end

          it 'says pending' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'pending')
          end
        end

        context 'and admin has OREID linked' do
          before do
            subject
          end

          it 'says pending' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'pending')
          end
        end
      end

      context 'and not logged in' do
        before do
          subject
        end

        it 'says pending' do
          expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'pending')
        end
      end
    end
  end

  context 'with a token supported by WalletConnect and Metamask' do
    let!(:transfer) { build(:blockchain_transaction).blockchain_transactable }
    let!(:project) { transfer.project }

    context 'when transfer is paid' do
      before do
        transfer.paid!
        create(
          :blockchain_transaction,
          blockchain_transactable: transfer,
          token: transfer.token,
          amount: 100,
          tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d',
          source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
          destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451'
        )
        subject
      end

      it 'links to blockchain transaction' do
        expect(page).to have_css('.transfers-table__transfer__status .transfer-button a', count: 1)
      end
    end

    context 'when transfer is accepted' do
      before do
        transfer.accepted!
      end

      context 'and token is frozen' do
        before do
          project.token.update!(token_frozen: true)
          subject
        end

        it 'says frozen' do
          expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'frozen')
        end
      end

      context 'and logged in as project admin' do
        before do
          login(project.account)
        end

        context 'and recepient does not have a wallet' do
          before do
            allow_any_instance_of(Award).to receive(:recipient_address).and_return(nil)
            subject
          end

          it 'says needs wallet' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'needs wallet')
          end
        end

        context 'and admin has a wallet' do
          before do
            transfer.blockchain_transactions.delete_all
            subject
          end

          it 'links to WalletConnect and Metamask controllers' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'Pay')
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button a[data-action="click->sign--wallet-connect#sendTx click->sign--metamask#sendTx"]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button a[data-sign--wallet-connect-target="txButtons"]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button a[data-sign--metamask-target="txButtons"]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button a[data-tx-new-url^=\/]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button a[data-tx-receive-url^=\/]', count: 1)
          end

          it 'links to WalletConnect controller' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'Pay')
          end
        end
      end

      context 'and logged in as transfer recepient' do
        before do
          login(transfer.account)
        end

        context 'and recepient does not have a wallet' do
          before do
            allow_any_instance_of(Award).to receive(:recipient_address).and_return(nil)
            subject
          end

          it 'links to Wallets' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button a', count: 1, text: 'set wallet')
          end
        end

        context 'and admin has wallet' do
          before do
            subject
          end

          it 'says pending' do
            expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'pending')
          end
        end
      end

      context 'and not logged in' do
        before do
          subject
        end

        it 'says pending' do
          expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1, text: 'pending')
        end
      end
    end
  end
end
