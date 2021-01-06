require 'rails_helper'

describe 'transfers_index_page', js: true do
  let(:owner) { create :account }
  let!(:project) { create :project, token: nil, account: owner }
  let!(:project_award_type) { (create :award_type, project: project) }

  it 'returns transfers ordered by create desc' do
    create(:award, name: 'second', status: :paid, award_type: project_award_type)
    create(:award, name: 'first', status: :paid, award_type: project_award_type)

    login(owner)
    visit project_dashboard_transfers_path(project)
    page.find :css, '#select_transfers', wait: 20 # wait for page to load

    expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(2)
    expect(page.all(:xpath, './/div[@class="transfers-table__transfer__name"]/h3/a').map(&:text)).to eq %w[first second]
  end

  it 'returns transfer form with category selected' do
    login(owner)
    visit project_dashboard_transfers_path(project)
    page.find :css, '#select_transfers', wait: 20

    select('earned', from: 'select_transfers')

    expect(find('#select_transfers').find('option[selected]').text).to eq('earned')
    page.find :css, '.transfers-table__transfer--new', wait: 10

    expect(page).to have_content('Earned')
  end

  it 'redirect to Transfer Categories page' do
    login(owner)
    visit project_dashboard_transfers_path(project)
    page.find :css, '#select_transfers', wait: 20

    select('Manage Categories', from: 'select_transfers').click

    expect(page).to have_current_path(project_dashboard_transter_categories_path(project))
  end
end
