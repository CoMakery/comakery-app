require 'rails_helper'

describe 'test_ready_filter', js: true do
  let(:owner) { create :account }
  let!(:project) { create :project, token: create(:comakery_dummy_token), account: owner, visibility: 'public_listed' }
  let!(:wallet) { create :wallet, account: owner, address: '0xD8655aFe58B540D8372faaFe48441AeEc3bec423', _blockchain: project.token._blockchain }
  let!(:project_award_type) { (create :award_type, project: project) }
  let!(:verification) { create(:verification, account: owner) }

  [1, 5, 10].each do |number_of_transfers|
    context "With #{number_of_transfers} ready transfers" do
      it "Doesn't duplicate transfers" do
        number_of_transfers.times do
          create(:transfer, award_type: project_award_type, account: owner)
        end

        login(owner)
        visit project_path(project)
        click_link 'transfers'
        page.find :css, '.transfers-create', wait: 20 # wait for page to load

        # verify number of transfers before applying filter
        expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(number_of_transfers)

        select('ready', from: 'transfers-filters--filter--options--select')
        page.find :xpath, '//select[@id="transfers-filters--filter--options--select"]/option[@selected="selected" and contains (text(), "ready")]', wait: 20 # wait for page to reload

        # verify number of transfers after applying filter
        expect(page.all(:xpath, './/div[@class="transfers-table__transfer"]').size).to eq(number_of_transfers)
      end
    end
  end

  it 'orders by issuer first_name' do
    issuer1 = create(:account, first_name: 'John', last_name: 'Snow')
    issuer2 = create(:account, first_name: 'Ned', last_name: 'Stark')
    create(:transfer, award_type: project_award_type, account: owner, issuer: issuer1)
    create(:transfer, award_type: project_award_type, account: owner, issuer: issuer2)

    login(owner)
    visit project_path(project)
    click_link 'transfers'
    page.find :css, '.transfers-create', wait: 20 # wait for page to load

    page.find(:css, '.transfers-table__transfer__issuer a.sort_link').click

    expect(page).to have_css '.transfers-table__transfer__issuer a.sort_link.asc', wait: 20
  end
end
