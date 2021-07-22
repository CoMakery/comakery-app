require 'rails_helper'

describe 'test_cancelled_filter', js: true do
  let!(:project) { create :project, token: create(:comakery_dummy_token) }
  let!(:project_award_type) { (create :award_type, project: project) }
  let!(:award) { create(:award, status: :cancelled, project: project, award_type: project_award_type) }

  before do
    # TODO: Remove me after fixing "eager loading detected Award => [:latest_transaction_batch]"
    Bullet.raise = false

    login(project.account)

    visit project_dashboard_transfers_path(project)
  end

  it 'returns correct number of transfers after applying filter' do
    # Display Header and Summary selectors (2)
    expect(page).to have_css('.transfers-table__transfer', count: 2)

    select('cancelled', from: 'filter-status-select')

    expect(page).to have_css('.transfers-table__transfer', count: 3)
  end
end
