require "rails_helper"

describe "when redeeming revenue shares for payments" do
  let!(:owner) { create(:account) }
  let!(:owner_auth) { create(:authentication, account: owner, slack_team_id: "lazercats", slack_image_32_url: "http://avatar.com/owner.jpg") }
  let!(:other_account) { create(:account) }
  let!(:other_account_auth) { create(:authentication, account: other_account, slack_team_id: "lazercats", slack_image_32_url: "http://avatar.com/other.jpg") }

  let!(:project) { create(:project,
                          royalty_percentage: 100,
                          public: true,
                          owner_account: owner,
                          slack_team_id: "lazercats",
                          require_confidentiality: false) }
  let!(:revenue) { create(:revenue, project: project, amount: 1234.5, currency: 'USD') }

  let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1, name: 'Code Contribution') }


  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1'*40}") }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account, slack_team_id: "lazercats", slack_team_name: "Lazer Cats") }

  let!(:ray_dog_account) { create(:account, ethereum_wallet: "0x#{'1'*40}") }
  let!(:ray_dog_auth) { create(:authentication, account: ray_dog_account, slack_team_id: "raydogs", slack_team_name: "Ray Dogs") }

  before do
    stub_slack_user_list
    stub_slack_channel_list

    award_type.awards.create_with_quantity(50, issuer: owner, authentication: same_team_account_authentication)
    award_type.awards.create_with_quantity(50, issuer: owner, authentication: owner_auth)
  end

  it 'revenue page looks sensible when there are no entries recorded yet' do
    login owner
    visit project_path(project)
    click_link "Payments"

    within ".payments" do
      expect(page).to_not have_css('table')
      expect(page).to have_content('No payments yet.')
    end
  end

  it "contributor can redeem revenue shares" do
    login same_team_account
    visit project_path(project)

    click_link "Payments"

    within('.my-balance') do
      expect(page.find('.total-awards-remaining')).to have_content('50')
      expect(page.find('.total-revenue-unpaid')).to have_content('$617.25')
    end

    within('.current-share-value') do
      expect(page.find('.revenue-per-share')).to have_content(/^\$12.34500000$/)
    end

    fill_in :payment_quantity_redeemed, with: 2
    click_on "Redeem My Revenue Shares"


    within ".payments" do
      expect(page.find('.payee')).to have_content(same_team_account_authentication.display_name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content(/^\$12.34500000$/)
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.status')).to have_content('Unpaid')
      expect(page.find('.transaction-fee').value).to be_blank
    end


    within('.my-balance') do
      expect(page.find('.total-awards-remaining')).to have_content('48')
      expect(page.find('.total-revenue-unpaid')).to have_content('$592.56')
    end

    within('.current-share-value') do
      expect(page.find('.revenue-per-share')).to have_content(/^\$12.34500000$/)
    end
  end

  it "owner can reconcile revenue shares" do
    login owner
    visit project_path(project)
    click_link "Payments"
    fill_in :payment_quantity_redeemed, with: 2
    click_on "Redeem My Revenue Shares"


    within ".payments" do
      expect(page.find('.payee')).to have_content(same_team_account_authentication.display_name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content('$12.34500000')
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.transaction-fee').value).to be_blank
      expect(page.find('.status')).to have_content('Unpaid')

      fill_in :payment_transaction_fee, with: '0.50'
      fill_in :payment_transaction_reference, with: 'xyz123abc'
      click_on "Reconcile"
    end

    within ".payments" do
      expect(page.find('.payee')).to have_content(same_team_account_authentication.display_name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content('$12.34500000')
      expect(page.find('.total-value')).to have_content('$24.69')

      expect(page.find('.transaction-fee')).to have_content("$0.50")
      expect(page.find('.status')).to have_content(/^Paid$/)

      expect(page.all('.issuer')[0]).to have_content("John Doe")
      expect(page.all('.issuer')[0]).to have_css("img[src*='http://avatar.com/owner.jpg']")
    end
  end

  it "non team member of public project can't redeem shares" do
    login ray_dog_account
    visit project_path(project)
    click_link "Payments"

    page.assert_selector('#new_payment', count: 0)
  end

  it 'payments appear in reverse chronological order' do
    login owner
    visit project_path(project)
    click_link "Payments"

    [3, 2, 1].each do |amount|
      fill_in :payment_quantity_redeemed, with: amount
      click_on "Redeem My Revenue Shares"
    end

    within ".payments" do
      expect(page.all('.total-value')[0]).to have_content('$12.34')
      expect(page.all('.total-value')[1]).to have_content('$24.69')
      expect(page.all('.total-value')[2]).to have_content('$37.03')
    end
  end

  it "non-project owner cannot reconcile payments" do
    login same_team_account
    visit project_path(project)
    click_link "Payments"
    fill_in :payment_quantity_redeemed, with: 2
    click_on "Redeem My Revenue Shares"

    within ".payments" do
      expect(page.find('.payee')).to have_content(same_team_account_authentication.display_name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content('$12.34500000')
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.transaction-fee').value).to be_blank
      expect(page.find('.status')).to have_content('Unpaid')

      page.assert_selector('input', count: 0)
    end
  end

  describe 'when share value can be calculated' do
    before do
      project.update(royalty_percentage: 10)
      login owner
      visit project_path(project)
      visit project_path(project)
      click_link "Payments"

      [3, 2, 1].each do |amount|
        fill_in :payment_quantity_redeemed, with: amount
        click_on "Redeem My Revenue Shares"
      end
    end

    it 'share value appears on project page' do
      visit project_path(project)
      expect(page.find('.my-balance')).to have_content('$54.32')
    end

    it 'holdings value appears on the project show page' do
      award_type.awards.create_with_quantity(7, issuer: owner, authentication: owner_auth)
      visit project_path(project)
      expect(page.find('.my-share')).to have_content('51')
      expect(page.find('.my-balance')).to have_content('$58.60')

      award_type.awards.create_with_quantity(1, issuer: owner, authentication: owner_auth)
      award_type.awards.create_with_quantity(5, issuer: owner, authentication: other_account_auth)
      visit project_path(project)

      expect(page.find('.my-share')).to have_content('52')
      expect(page.find('.my-balance')).to have_content('$56.40')
    end
  end

  xit 'updates the contributors page' do
    project.update(royalty_percentage: 10)
    award_type.awards.create_with_quantity(7, issuer: owner, authentication: owner_auth)
    award_type.awards.create_with_quantity(5, issuer: owner, authentication: other_account_auth)

    login owner
    visit project_path(project)
    click_link "Payments"

    [3, 2, 1].each do |amount|
      fill_in :payment_quantity_redeemed, with: amount
      click_on "Redeem My Revenue Shares"
    end

    visit project_contributors_path(project)
    contributor_holdings = page.all('.holdings-value')
    expect(contributor_holdings.size).to eq(2)
    expect(contributor_holdings[0]).to have_content("$0.35")
    expect(contributor_holdings[1]).to have_content("$0.25")
  end

  it 'shows errors if there were missing fields' do
    login owner
    visit project_path(project)
    click_link "Payments"

    click_on "Redeem My Revenue Shares"
    expect(page.all('.amount').size).to eq(0)
    within('form#new_payment') do
      expect(page.find('small.error')).to have_text("can't be blank")
    end
  end

  describe 'it displays correct currency precision for' do
    let!(:project) { create(:project,
                            royalty_percentage: 100,
                            public: true,
                            owner_account: owner,
                            slack_team_id: "foo",
                            require_confidentiality: false) }

    before do
    end

    describe 'usd' do
      let!(:project) { create(:project,
                              royalty_percentage: 100,
                              public: true,
                              owner_account: owner,
                              slack_team_id: "lazercats",
                              require_confidentiality: false) }
      specify do
        login owner
        project.revenues.create(amount: 4321, recorded_by: owner, currency: 'USD')

        visit project_path(project)
        click_link "Payments"

        fill_in :payment_quantity_redeemed, with: "50"
        click_on "Redeem My Revenue Shares"

        expect(page.find('.payee')).to have_content('John Doe')
        expect(page.find('.quantity-redeemed')).to have_content('50')
        expect(page.find('.share-value')).to have_content('$55.55500000')
        expect(page.find('.total-value')).to have_content('$2,777.75')
      end
    end

    describe 'btc' do
      let!(:project) { create(:project,
                              royalty_percentage: 100,
                              public: true,
                              owner_account: owner,
                              slack_team_id: "lazercats",
                              require_confidentiality: false,
                              denomination: 'BTC') }
      specify do
        login owner
        visit project_path(project)
        click_link "Payments"

        fill_in :payment_quantity_redeemed, with: "50"
        click_on "Redeem My Revenue Shares"

        expect(page.find('.payee')).to have_content('John Doe')
        expect(page.find('.quantity-redeemed')).to have_content('50')
        expect(page.find('.share-value')).to have_content("฿12.34500000")
        expect(page.find('.total-value')).to have_content("฿617.25000000")
      end
    end

    describe 'eth' do
      let!(:project) { create(:project,
                              royalty_percentage: 100,
                              public: true,
                              owner_account: owner,
                              slack_team_id: "lazercats",
                              require_confidentiality: false,
                              denomination: 'ETH') }
      specify do
        login owner
        visit project_path(project)
        click_link "Payments"

        fill_in :payment_quantity_redeemed, with: "50"
        click_on "Redeem My Revenue Shares"

        expect(page.find('.payee')).to have_content('John Doe')
        expect(page.find('.quantity-redeemed')).to have_content('50')
        expect(page.find('.share-value')).to have_content("Ξ12.34500000")
        expect(page.find('.total-value')).to have_content("Ξ617.25000000")
      end
    end
  end

  it "no payments page displayed for project_coins" do
    project.project_coin!

    login owner
    visit project_path(project)

    expect(page).to_not have_link "Payments"

    visit project_payments_path(project)
    expect(page).to have_current_path(root_path)
  end

  it "no payments page displayed when 0% royalty percentage" do
    project.update_attributes(royalty_percentage: 0)

    login owner
    visit project_path(project)

    expect(page).to_not have_link "Payments"

    visit project_payments_path(project)
    expect(page).to have_current_path(root_path)
  end

  describe 'non-members' do
    before do
      project.update_attributes(require_confidentiality: false, public: true)
      visit logout_path
    end

    it "non-members can see payments if confidentiality isn't required for a public project" do
      visit project_path(project)

      expect(page).to have_link "Payments"

      visit project_payments_path(project)
      expect(page).to have_current_path(project_payments_path(project))
    end

    it "non-members can't see payments if confidentiality is required for a public project" do
      project.update_attribute(:require_confidentiality, true)

      visit project_path(project)
      expect(page).to_not have_link "Payments"

      visit project_payments_path(project)
      expect(page).to have_current_path(root_path)
    end

    it "non-members can't see payments if it's a private project" do
      project.update_attribute(:public, false)

      visit project_path(project)
      expect(page).to_not have_link "Payments"

      visit project_payments_path(project)
      expect(page).to have_current_path("/404.html")
    end
  end
end