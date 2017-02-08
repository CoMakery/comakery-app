require "rails_helper"

describe "", :js do
  let!(:owner) { create(:account) }
  let!(:owner_auth) { create(:authentication, account: owner, slack_team_id: "foo", slack_image_32_url: "http://avatar.com/owner.jpg") }
  let!(:other_account) { create(:account) }
  let!(:other_account_auth) { create(:authentication, account: other_account, slack_team_id: "foo", slack_image_32_url: "http://avatar.com/other.jpg") }
  let!(:project) { create(:project, public: true, owner_account: owner, slack_team_id: "foo") }
  let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1000, name: 'Code Contribution') }

  before do
    stub_slack_user_list
    stub_slack_channel_list
  end

  it "project owner can record revenues" do
    login owner
    visit project_path(project)
    click_link "Revenues"

    fill_in :revenue_amount, with: 10
    fill_in :revenue_comment, with: "A comment"
    fill_in :revenue_transaction_reference, with: "0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098"
    click_on "Record Revenue"

    within ".revenues" do
      expect(page.all('.transaction-reference')[0]).to have_content('0e3e2357e806b6cdb1f70b54c3a3a17b6714ee1f0e68bebb44a74b1efd512098')
      expect(page.all('.comment')[0]).to have_content('A comment')
      expect(page).to have_content('$10.00')
    end
  end

  it 'revenues appear in reverse chronological order' do
    login owner
    visit project_path(project)
    click_link "Revenues"

    [3, 2, 1].each do |amount|
      fill_in :revenue_amount, with: amount
      click_on "Record Revenue"
    end

    within ".revenues" do
      expect(page.all('.amount')[0]).to have_content('$1.00')
      expect(page.all('.amount')[1]).to have_content('$2.00')
      expect(page.all('.amount')[2]).to have_content('$3.00')
    end

  end

  it "non-project owner cannot record revenues" do
    login other_account

    visit project_path(project)
    click_link "Revenues"

    expect(page).to_not have_css('.new_revenue')
  end

  it 'project members can see a summary of the project state' do
    project.update(royalty_percentage: 10)
    project.revenues.create(amount: 1000, currency: 'USD')
    project.revenues.create(amount: 270, currency: 'USD')
    award_type.awards.create_with_quantity(1.01, issuer: owner, authentication: owner_auth)

    login owner
    visit project_revenues_path(project)

    within('.summary') do
      expect(page.find('.revenue-shared')).to have_content("$127.00 Revenue Shared (10.0%)")
      expect(page.find('.total-awards')).to have_content("0")
      expect(page.find('.total-revenue')).to have_content("$1,270")
      expect(page.find('.per-revenue-share')).to have_content("$0.1257")
    end
  end

  describe 'when share value can be calculated' do
    before do
      project.update(royalty_percentage: 10)
      login owner
      visit project_path(project)
      click_link "Revenues"

      [3, 2, 1].each do |amount|
        fill_in :revenue_amount, with: amount
        click_on "Record Revenue"
      end
    end

    it 'share value appears on project page' do
      visit project_path(project)
      expect(page.find('.my-balance')).to have_content('$0.00 of $0.60')
    end

    it 'share value appears on project page' do
      visit project_path(project)
      expect(page.find('.my-balance')).to have_content('$0.00 of $0.60')
    end

    it 'holdings value appears on contributors page' do
      award_type.awards.create_with_quantity(7, issuer: owner, authentication: owner_auth)
      visit project_path(project)
      expect(page.find('.my-share')).to have_content('7,000 of 7,000')
      expect(page.find('.my-balance')).to have_content('$0.60 of $0.60')

      award_type.awards.create_with_quantity(5, issuer: owner, authentication: other_account_auth)
      visit project_path(project)
      expect(page.find('.my-share')).to have_content('7,000 of 12,000')
      expect(page.find('.my-balance')).to have_content('$0.35 of $0.60')
    end
  end

  xit 'updates the contributors page'

  xdescribe "with different project currency denomination"
  xit "non-members can see revenues if it's a public project"
  xit "non-members can't see revenues if it's a private project"
  xit "no revenues page displayed for project_coins"
  xit "no revenues page displayed when 0% royalty percentage"
  xit "no revenues page displayed when nil royalty percentage"
end