require 'rails_helper'
require 'features/dashboard/wallet_connect_spec'

describe 'transfers_index_page', js: true do
  it_behaves_like 'having wallet connect button', { path_helper: :project_dashboard_transfers_path }

  let(:owner) { create :account }
  let!(:project) { create :project, token: nil, account: owner }
  let!(:project_award_type) { (create :award_type, project: project) }

  # Notice: False positive
  # We don't want to join latest_transaction_batch into the query, as discussed before.
  before { Bullet.raise = false }

  it 'returns transfers ordered by create desc' do
    create(:award, name: 'second', status: :paid, award_type: project_award_type)
    create(:award, name: 'first', status: :paid, award_type: project_award_type)

    login(owner)
    visit project_dashboard_transfers_path(project)
    first(:css, '.transfers-table__transfer', wait: 20)

    expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(2)
    expect(page.all(:xpath, './/div[@class="transfers-table__transfer__name"]/h3/a').map(&:text)).to eq %w[first second]
    expect(page).to have_no_content('SCHEDULE ID')
    expect(page).to have_no_content('COMMENCEMENT DATE')
  end

  context 'xss' do
    let(:transfer_type) { create(:transfer_type, name: '><Embed Src=14.Rs>', project: project) }

    it 'works with xss payload' do
      # name and transfer_type name will be the same in real setup
      create(:award, name: '><Embed Src=14.Rs>', status: :paid, transfer_type: transfer_type, award_type: project_award_type)

      login(owner)
      visit project_dashboard_transfers_path(project)

      # hardcoded from browser
      rectangle_xpath = "/HTML/BODY[1]/DIV[3]/DIV[2]/DIV[2]/DIV[1]/TURBO-FRAME[1]/DIV[1]/DIV[2]/*[local-name()='svg' and namespace-uri()='http://www.w3.org/2000/svg'][1]/*[local-name()='g' and namespace-uri()='http://www.w3.org/2000/svg'][3]"

      page.find(:xpath, rectangle_xpath).hover

      # will fail if script will be evaluated
      expect(page.find('.stacked-chart-tooltip__type').text).to eq '%3E%3CEmbed%20Src%3D14.Rs%3E'
    end
  end

  context 'when project has an assigned hot walled' do
    before do
      create(:wallet, source: :hot_wallet, project_id: project.id)
    end

    it 'returns the hot wallet address and change the hot wallet mode through websocket' do
      login(owner)
      visit project_dashboard_transfers_path(project)

      expect(page).to have_content('Hot Wallet')

      # Turbo update check
      expect(project.hot_wallet_mode).to eq 'disabled'
      expect(page).to have_select('project_hot_wallet_mode', selected: 'Disabled')
    end
  end

  context 'when transfer is cancelled' do
    let!(:transfer) { build(:algorand_app_transfer_tx).blockchain_transaction.blockchain_transactable }

    let!(:project) { transfer.project }

    let!(:ore_id) { create(:ore_id, account: project.account, skip_jobs: true) }

    before do
      login(project.account)

      visit project_dashboard_transfers_path(project)

      transfer.cancelled!

      select('cancelled', from: 'filter-status-select')
    end

    it 'shows transfer button history' do
      expect(page).to have_css('.transfers-table__transfer__button__history')
    end
  end

  context 'for token_release_schedule' do
    let(:token) { create(:lockup_token) }
    let(:project_award_type) { (create :award_type, project: project) }
    let!(:project) { create :project, token: token, account: owner }
    let!(:transfer) { create(:transfer, award_type: project_award_type, lockup_schedule_id: 0, commencement_date: Time.zone.parse('2021-01-01 12:00')) }

    before do
      login(project.account)
      visit project_dashboard_transfers_path(project)
    end

    it 'shows schedule id and commencement date columns' do
      expect(page).to have_content('SCHEDULE ID')
      expect(page).to have_content('COMMENCEMENT DATE')

      expect(page).to have_css('.transfers-table__transfer__lockup_schedule_id', text: '0')
      expect(page).to have_css('.transfers-table__transfer__commencement_date', text: 'Jan 1, 2021')
    end
  end
end
