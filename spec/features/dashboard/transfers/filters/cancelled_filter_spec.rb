require 'rails_helper'

describe 'test_cancelled_filter', js: true do
  let(:owner) { create :account }
  let!(:project) { create :project, token: create(:comakery_dummy_token), account: owner }
  let!(:project_award_type) { (create :award_type, project: project) }

  # TODO: Remove me after fixing "eager loading detected Award => [:latest_transaction_batch]"
  before { Bullet.raise = false }

  [1, 6, 9].each do |number_of_transfers|
    context "With #{number_of_transfers} cancelled transfers" do
      it 'Returns correct number of transfers after applying filter' do
        number_of_transfers.times do
          create(:award, status: :cancelled, award_type: project_award_type)
        end

        login(owner)
        visit project_path(project)
        click_link 'transfers'

        first(:css, '.transfers-table__transfer')

        # verify number of transfers before applying filter is 0 (cancelled transfers are not displayed by default)
        expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(0)

        select('cancelled', from: 'filter-status-select')
        page.find :xpath, '//select[@id="filter-status-select"]/option[@selected="selected" and contains (text(), "cancelled")]'

        # verify number of transfers after applying filter
        expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(number_of_transfers)
      end
    end
  end
end
