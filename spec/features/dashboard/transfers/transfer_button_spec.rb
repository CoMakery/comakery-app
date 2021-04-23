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
end
