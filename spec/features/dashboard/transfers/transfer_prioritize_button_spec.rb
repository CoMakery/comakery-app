require 'rails_helper'

describe 'transfer prioritize button on transfers page', js: true do
  let!(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }

  let!(:project) { transfer.project }

  let!(:ore_id) { create(:ore_id, account: project.account, skip_jobs: true) }

  before { create(:wallet, source: :hot_wallet, project_id: project.id) }

  before { project.update!(hot_wallet_mode: :auto_sending) }

  before { transfer.accepted! }

  before { login(project.account) }

  context 'when blockchain transaction' do
    let(:blockchain_transaction) do
      create(
        :blockchain_transaction,
        blockchain_transactables: transfer,
        token: transfer.token,
        amount: 1,
        tx_hash: 'MNGGXTRI4XE6LQJQ3AW3PBBGD5QQFRXMRSXZFUMHTKJKFEQ6TZ2A',
        source: 'YFGM3UODOZVHSI4HXKPXOKFI6T2YCIK3HKWJYXYFQBONJD4D3HD2DPMYW4',
        destination: 'E3IT2TDWEJS55XCI5NOB2HON6XUBIZ6SDT2TAHTKDQMKR4AHEQCROOXFIE'
      )
    end

    context 'with pending status' do
      before { blockchain_transaction.update(status: :pending) }

      it 'isn\'t present' do
        visit project_dashboard_transfers_path(project)

        expect(page).to have_no_css('.transfers-table__transfer__button__history #prioritizeBtn')
      end
    end

    context 'with created status' do
      before { blockchain_transaction.update(status: :created) }

      context 'when hot wallet mode is auto sending' do
        it 'has link to prioritize' do
          visit project_dashboard_transfers_path(project)

          expect(page).to have_css('.transfers-table__transfer__button__history #prioritizeBtn', count: 1)
          expect(find('.transfers-table__transfer__button__history #prioritizeBtn').text).to eq('PRIORITIZE')
        end
      end

      context 'when hot wallet mode is manual sending' do
        before { project.update(hot_wallet_mode: :manual_sending) }

        it 'has link to pay by hot wallet' do
          visit project_dashboard_transfers_path(project)

          expect(page).to have_css('.transfers-table__transfer__button__history #prioritizeBtn', count: 1)
          expect(find('.transfers-table__transfer__button__history #prioritizeBtn').text).to eq('PAY BY HOT WALLET')
        end
      end
    end
  end
end
