require 'rails_helper'

describe 'transfer button on Transfers page' do
  let!(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }
  let!(:project) { transfer.project }
  let!(:ore_id) { create(:ore_id, account: project.account, skip_jobs: true) }

  before do
    project.update!(visibility: :public_listed)
  end

  subject { visit project_dashboard_transfers_path(project) }

  context 'without a token' do
    before do
      transfer.ready!
      project.update!(token: nil)
      subject
    end

    it 'is not present' do
      expect(page).not_to have_css('.transfers-table__transfer__button .transfer-button')
    end
  end

  context 'when transfer is cancelled' do
    before do
      transfer.cancelled!
      subject
    end

    it 'is not present' do
      expect(page).not_to have_css('.transfers-table__transfer__button .transfer-button')
    end
  end

  context 'with a token supported by OREID' do
    context 'when transfer is paid' do
      before do
        transfer.paid!
        create(
          :blockchain_transaction,
          blockchain_transactables: transfer,
          token: transfer.token,
          amount: 1,
          tx_hash: 'MNGGXTRI4XE6LQJQ3AW3PBBGD5QQFRXMRSXZFUMHTKJKFEQ6TZ2A',
          source: 'YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4',
          destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
        )
        subject
      end

      it 'links to blockchain transaction' do
        expect(page).to have_css('.transfers-table__transfer__status .transfer-button', count: 1)
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
          expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'frozen')
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
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'needs wallet')
          end
        end

        context 'and admin does not have OREID linked' do
          before do
            project.account.update!(ore_id_account: nil)
            subject
          end

          it 'links to Wallets' do
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'link OREID')
          end
        end

        context 'and admin has OREID linked' do
          before do
            subject
          end

          it 'links to OREID' do
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'PAY')
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
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'pending')
          end
        end

        context 'and admin has OREID linked' do
          before do
            subject
          end

          it 'says pending' do
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'pending')
          end
        end
      end

      context 'and not logged in' do
        before do
          subject
        end

        it 'says pending' do
          expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'pending')
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
          blockchain_transactables: transfer,
          token: transfer.token,
          amount: 100,
          tx_hash: '0x5d372aec64aab2fc031b58a872fb6c5e11006c5eb703ef1dd38b4bcac2a9977d',
          source: '0x66ebd5cdf54743a6164b0138330f74dce436d842',
          destination: '0x8599d17ac1cec71ca30264ddfaaca83c334f8451'
        )
        subject
      end

      it 'links to blockchain transaction' do
        expect(page).to have_css('.transfers-table__transfer__status .transfer-button ', count: 1)
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
          expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'frozen')
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
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'needs wallet')
          end
        end

        context 'and admin has a wallet' do
          before do
            BlockchainTransaction.delete_all
            subject
          end

          it 'links to WalletConnect and Metamask controllers' do
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'Pay')
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button a[data-action="click->sign--wallet-connect#sendTx click->sign--metamask#sendTx"]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button a[data-sign--wallet-connect-target="txButtons"]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button a[data-sign--metamask-target="txButtons"]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button a[data-tx-new-url^=\/]', count: 1)
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button a[data-tx-receive-url^=\/]', count: 1)
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
            expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'pending')
          end
        end
      end

      context 'and not logged in' do
        before do
          subject
        end

        it 'says pending' do
          expect(page).to have_css('.transfers-table__transfer__button .transfer-button', count: 1, text: 'pending')
        end
      end
    end
  end
end
