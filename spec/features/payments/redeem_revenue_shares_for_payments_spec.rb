# frozen_string_literal: true

require 'rails_helper'

describe 'when redeeming revenue shares for payments' do
  let!(:team) { create :team }
  let!(:owner) { create(:account) }
  let!(:owner_auth) { create(:authentication, account: owner) }
  let!(:other_account) { create(:account) }
  let!(:other_account_auth) { create(:authentication, account: other_account) }

  let!(:project) do
    create(:project,
      royalty_percentage: 100,
      visibility: 'public_listed',
      payment_type: 'revenue_share',
      account: owner,
      require_confidentiality: false)
  end
  let!(:revenue) { create(:revenue, project: project, amount: 1234.5, currency: 'USD') }

  let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1, name: 'Code Contribution') }

  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1' * 40}") }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account) }

  let!(:ray_dog_account) { create(:account, ethereum_wallet: "0x#{'1' * 40}") }
  let!(:ray_dog_auth) { create(:authentication, account: ray_dog_account) }

  before do
    team.build_authentication_team owner_auth
    team.build_authentication_team other_account_auth
    team.build_authentication_team same_team_account_authentication

    stub_slack_user_list
    stub_slack_channel_list

    channel = project.channels.create(team: team, channel_id: 'general')
    create :award, quantity: 50, issuer: owner, account: owner, channel: channel, award_type: award_type
    create :award, quantity: 50, issuer: owner, account: same_team_account, channel: channel, award_type: award_type
  end

  it 'revenue page looks sensible when there are no entries recorded yet' do
    login owner
    visit project_path(project)
    click_link 'Payments'

    within '.payments' do
      expect(page).not_to have_css('table')
      expect(page).to have_content('No payments yet.')
    end
  end

  it 'contributor can redeem revenue shares' do
    login same_team_account
    visit project_path(project)

    click_link 'Payments'

    within('.current-share-value') do
      expect(page.find('.revenue-per-share')).to have_content(/^\$12.34500000$/)
    end

    fill_in :payment_quantity_redeemed, with: 2
    click_on 'Redeem My Revenue Shares'

    within '.payments' do
      expect(page.find('.payee')).to have_content(same_team_account.decorate.name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content(/^\$12.34500000$/)
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.status')).to have_content('Unpaid')
      expect(page.find('.transaction-fee').value).to be_blank
    end

    within('.current-share-value') do
      expect(page.find('.revenue-per-share')).to have_content(/^\$12.34500000$/)
    end
  end

  it "non team member of public project can't redeem shares" do
    login ray_dog_account
    visit project_path(project)
    click_link 'Payments'

    page.assert_selector('#new_payment', count: 0)
  end

  it 'payments appear in reverse chronological order' do
    login owner
    visit project_path(project)
    click_link 'Payments'

    [3, 2, 1].each do |amount|
      fill_in :payment_quantity_redeemed, with: amount
      click_on 'Redeem My Revenue Shares'
    end

    within '.payments' do
      expect(page.all('.total-value')[0]).to have_content('$12.34')
      expect(page.all('.total-value')[1]).to have_content('$24.69')
      expect(page.all('.total-value')[2]).to have_content('$37.03')
    end
  end

  describe 'when shares have been redeemed' do
    before do
      project.update(royalty_percentage: 10)
      login owner
      visit project_path(project)
      visit project_path(project)
      click_link 'Payments'

      [3, 2, 1].each do |amount|
        fill_in :payment_quantity_redeemed, with: amount
        click_on 'Redeem My Revenue Shares'
      end
    end

    specify do
      expect(page.find('#flash-msg-notice')).to have_content('$1.23 pending payment by the project owner')
    end

    it 'holdings value appears on the project show page' do
      award_type.awards.create_with_quantity(7, issuer: owner, account: owner)
      visit project_path(project)

      award_type.awards.create_with_quantity(1, issuer: owner, account: owner)
      award_type.awards.create_with_quantity(5, issuer: owner, account: other_account)
      visit project_path(project)
    end
  end

  it 'shows errors if there were missing fields' do
    login owner
    visit project_path(project)
    click_link 'Payments'

    click_on 'Redeem My Revenue Shares'
    expect(page.all('.amount').size).to eq(0)
    within('form#new_payment') do
      expect(page).to have_text("can't be blank")
    end
  end

  it 'has a grayed out form if the user has 0 revenue shares' do
    login other_account
    visit project_path(project)
    click_link 'Payments'

    expect(page).to have_content('Earn awards by contributing')
    within('.no-awards-message') { click_on 'awards' }
    expect(current_path).to eq(project_path(project))
  end

  it 'does not have a grayed out form if the user has > 0 revenue shares' do
    login owner
    visit project_path(project)
    project.revenues.create(amount: 4321, recorded_by: owner, currency: 'USD')
    click_link 'Payments'

    expect(page).to have_content 'of my 50 revenue shares'
    expect(page.find('form#new_payment #payment_quantity_redeemed').disabled?).to eq(false)
    expect(page.find('form#new_payment input[type=submit]').disabled?).to eq(false)
  end

  describe 'it displays correct currency precision for' do
    let!(:project) do
      create(:project,
        royalty_percentage: 100,
        visibility: 'public_listed',
        account: owner,
        require_confidentiality: false)
    end

    describe 'usd' do
      let!(:project) do
        create(:project,
          royalty_percentage: 100,
          visibility: 'public_listed',
          payment_type: 'revenue_share',
          account: owner,
          require_confidentiality: false)
      end

      specify do
        login owner
        project.revenues.create(amount: 4321, recorded_by: owner, currency: 'USD')

        visit project_path(project)
        click_link 'Payments'

        fill_in :payment_quantity_redeemed, with: '50'
        click_on 'Redeem My Revenue Shares'

        expect(page.find('.payee')).to have_content(owner.decorate.name)
        expect(page.find('.quantity-redeemed')).to have_content('50')
        expect(page.find('.share-value')).to have_content('$55.55500000')
        expect(page.find('.total-value')).to have_content('$2,777.75')
      end

      it 'shows errors' do
        login owner
        project.revenues.create(amount: 4321, recorded_by: owner, currency: 'USD')

        visit project_path(project)
        click_link 'Payments'

        click_on 'Redeem My Revenue Shares'
        expect(page.first('.error')).to have_content 'Total value must be greater than or equal to $1'
        expect(page.all('.error')[1]).to have_content "Quantity redeemed can't be blank and is not a number"
      end

      it 'displays the minimum payment amount' do
        login owner
        visit project_path(project)
        click_link 'Payments'
        expect(page.first('.min-transaction-amount')).to have_content 'The minimum transaction amount is $1'
      end
    end

    describe 'btc' do
      let!(:project) do
        create(:project,
          royalty_percentage: 100,
          visibility: 'public_listed',
          payment_type: 'revenue_share',
          account: owner,
          require_confidentiality: false,
          denomination: 'BTC')
      end

      specify do
        login owner
        visit project_path(project)
        click_link 'Payments'

        fill_in :payment_quantity_redeemed, with: '50'
        click_on 'Redeem My Revenue Shares'

        expect(page.find('.payee')).to have_content(owner.decorate.name)
        expect(page.find('.quantity-redeemed')).to have_content('50')
        expect(page.find('.share-value')).to have_content('฿12.34500000')
        expect(page.find('.total-value')).to have_content('฿617.25000000')
      end

      it 'must have correct minimum value' do
        login owner
        project.revenues.create(amount: 4321, recorded_by: owner, currency: 'BTC')

        visit project_path(project)
        click_link 'Payments'

        click_on 'Redeem My Revenue Shares'
        expect(page.first('.error')).to have_content 'Total value must be greater than or equal to ฿0.001'
      end

      it 'displays the minimum payment amount' do
        login owner
        visit project_path(project)
        click_link 'Payments'
        expect(page.first('.min-transaction-amount')).to have_content 'The minimum transaction amount is ฿0.001'
      end
    end

    describe 'eth' do
      let!(:project) do
        create(:project,
          royalty_percentage: 100,
          visibility: 'public_listed',
          payment_type: 'revenue_share',
          account: owner,
          require_confidentiality: false,
          denomination: 'ETH')
      end

      specify do
        login owner
        visit project_path(project)
        click_link 'Payments'

        fill_in :payment_quantity_redeemed, with: '50'
        click_on 'Redeem My Revenue Shares'

        expect(page.find('.payee')).to have_content(owner.decorate.name)
        expect(page.find('.quantity-redeemed')).to have_content('50')
        expect(page.find('.share-value')).to have_content('Ξ12.34500000')
        expect(page.find('.total-value')).to have_content('Ξ617.25000000')
      end

      it 'must have correct minimum value' do
        login owner
        project.revenues.create(amount: 4321, recorded_by: owner, currency: 'ETH')

        visit project_path(project)
        click_link 'Payments'

        click_on 'Redeem My Revenue Shares'
        expect(page.first('.error')).to have_content 'Total value must be greater than or equal to Ξ0.1'
      end

      it 'displays the minimum payment amount' do
        login owner
        visit project_path(project)
        click_link 'Payments'
        expect(page.first('.min-transaction-amount')).to have_content 'The minimum transaction amount is Ξ0.1'
      end
    end
  end

  it 'no payments page displayed for project_tokens' do
    project.project_token!

    login owner
    visit project_path(project)

    expect(page).not_to have_link 'Payments'

    visit project_payments_path(project)
    expect(page).to have_current_path(my_project_path)
  end

  it 'no payments page displayed when 0% royalty percentage' do
    project.update_attributes(royalty_percentage: 0)

    login owner
    visit project_path(project)

    expect(page).not_to have_link 'Payments'

    visit project_payments_path(project)
    expect(page).to have_current_path(my_project_path)
  end

  describe 'non-members' do
    before do
      project.update_attributes(require_confidentiality: false, visibility: 'public_listed')
      visit logout_path
    end

    it "non-members can see payments if confidentiality isn't required for a public project" do
      visit project_path(project)

      expect(page).to have_link 'Payments'

      visit project_payments_path(project)
      expect(page).to have_current_path(project_payments_path(project))
    end

    it "non-members can't see payments if confidentiality is required for a public project" do
      project.update_attribute(:require_confidentiality, true)

      visit project_path(project)
      expect(page).not_to have_link 'Payments'

      visit project_payments_path(project)
      expect(page).to have_current_path(root_path)
    end

    it "non-members can't see payments if it's a private project" do
      project.member!

      visit project_path(project)
      expect(page).not_to have_link 'Payments'

      visit project_payments_path(project)
      expect(page).to have_current_path('/404.html')
    end
  end
end
