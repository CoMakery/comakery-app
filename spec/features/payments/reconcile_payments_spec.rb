# frozen_string_literal: true

require 'rails_helper'

describe 'when reconciling redeemed revenue shares' do
  let!(:team) { create :team }
  let!(:owner) { create(:account, first_name: 'Owner') }
  let!(:owner_auth) { create(:authentication, account: owner) }
  let!(:other_account) { create(:account, first_name: 'Other') }
  let!(:other_account_auth) { create(:authentication, account: other_account) }

  let!(:project) do
    create(:project,
      royalty_percentage: 100,
      visibility: 'public_listed',
      account: owner,
      payment_type: 'revenue_share',
      require_confidentiality: false)
  end
  let!(:revenue) { create(:revenue, project: project, amount: 1234.5, currency: 'USD') }

  let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1, name: 'Code Contribution') }

  let!(:same_team_account) { create(:account, first_name: 'Bob', ethereum_wallet: "0x#{'1' * 40}") }
  let!(:same_team_account_authentication) { create(:authentication, account: same_team_account) }

  let!(:ray_dog_account) { create(:account, first_name: 'Ray', ethereum_wallet: "0x#{'1' * 40}") }
  let!(:ray_dog_auth) { create(:authentication, account: ray_dog_account) }

  before do
    team.build_authentication_team owner_auth
    team.build_authentication_team same_team_account_authentication
    stub_slack_user_list
    stub_slack_channel_list

    channel = project.channels.create(team: team, channel_id: 'general')
    create :award, quantity: 50, issuer: owner, account: owner, channel: channel, award_type: award_type
    create :award, quantity: 50, issuer: owner, account: same_team_account, channel: channel, award_type: award_type

    open(Rails.root.join('spec', 'fixtures', 'helmet_cat.png'), 'rb') do |file|
      owner.image = file
    end
    owner.save
  end

  it 'owner can reconcile revenue shares' do
    login owner
    visit project_path(project)
    click_link 'Payments'
    fill_in :payment_quantity_redeemed, with: 2
    click_on 'Redeem My Revenue Shares'

    within '.payments' do
      expect(page.find('.payee')).to have_content(owner.decorate.name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content('$12.34500000')
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.transaction-fee').value).to be_blank
      expect(page.find('.status')).to have_content('Unpaid')

      fill_in :payment_transaction_fee, with: '0.50'
      fill_in :payment_transaction_reference, with: 'xyz123abc'
      click_on 'Reconcile'
    end

    within '.payments' do
      expect(page.find('.payee')).to have_content(owner.decorate.name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content('$12.34500000')
      expect(page.find('.total-value')).to have_content('$24.69')

      expect(page.find('.transaction-fee')).to have_content('$0.50')
      expect(page.find('.status')).to have_content(/^Paid$/)

      expect(page.all('.issuer')[0]).to have_content('Owner')
    end
  end

  it 'owner sees errors if the transaction fee is higher than the total value' do
    login owner
    visit project_path(project)
    click_link 'Payments'
    fill_in :payment_quantity_redeemed, with: 2
    click_on 'Redeem My Revenue Shares'

    within '.payments' do
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.transaction-fee').value).to be_blank
      expect(page.find('.status')).to have_content('Unpaid')

      fill_in :payment_transaction_fee, with: '25'
      click_on 'Reconcile'
    end

    expect(page.find('#flash-msg-error')).to have_content('Total payment must be greater than or equal to 0')
  end

  it 'non-project owner cannot reconcile payments' do
    expect(same_team_account&.same_team_project?(project)).to eq true
    expect(same_team_account.total_awards_remaining(project) > 0).to eq true
    login same_team_account
    visit project_path(project)
    click_link 'Payments'
    fill_in :payment_quantity_redeemed, with: 2
    click_on 'Redeem My Revenue Shares'

    within '.payments' do
      expect(page.find('.payee')).to have_content(same_team_account.decorate.name)
      expect(page.find('.quantity-redeemed')).to have_content('2')
      expect(page.find('.share-value')).to have_content('$12.34500000')
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.transaction-fee').value).to be_blank
      expect(page.find('.status')).to have_content('Unpaid')

      page.assert_selector('input', count: 0)
    end
  end

  it 'other team member cannot reconcile payments' do
    login other_account
    visit project_path(project)
    click_link 'Payments'
    expect(page).to have_content 'by contributing to the project - then cash them out here for your share of the revenue'
  end
end
