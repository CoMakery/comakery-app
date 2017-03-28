require "rails_helper"

describe "when reconciling redeemed revenue shares" do
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

  it "owner sees errors if the transaction fee is higher than the total value" do
    login owner
    visit project_path(project)
    click_link "Payments"
    fill_in :payment_quantity_redeemed, with: 2
    click_on "Redeem My Revenue Shares"


    within ".payments" do
      expect(page.find('.total-value')).to have_content('$24.69')
      expect(page.find('.transaction-fee').value).to be_blank
      expect(page.find('.status')).to have_content('Unpaid')

      fill_in :payment_transaction_fee, with: '25'
      click_on "Reconcile"
    end

    expect(page.find("#flash-msg-error")).to have_content("Total payment must be greater than or equal to 0")
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
end