require 'rails_helper'

describe 'test_transferred_filter', js: true do
  let(:owner) { create :account }
  let!(:project) { create :project, token: nil, account: owner }
  let!(:project_award_type) { (create :award_type, project: project) }

  [1, 5, 9].each do |number_of_transfers|
    context "With #{number_of_transfers} completed transfers" do
      it 'Returns correct number of transfers after applying filter' do
        number_of_transfers.times do
          create(:award, status: :paid, award_type: project_award_type)
        end

        login(owner)
        visit project_path(project)
        click_link 'transfers'
        page.find :css, '#select_transfers', wait: 20 # wait for page to load

        # verify number of transfers before applying filter
        expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(number_of_transfers)

        select('transferred', from: 'transfers-filters--filter--options--select')
        page.find :xpath, '//select[@id="transfers-filters--filter--options--select"]/option[@selected="selected" and contains (text(), "transferred")]', wait: 20 # wait for page to reload

        # verify number of transfers after applying filter
        expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(number_of_transfers)
      end
    end
  end
end
