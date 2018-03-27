require 'rails_helper'

describe 'contributors/index.html.rb' do
  let!(:owner) { create(:account) }
  let(:authentication) { create :authentication }
  let(:project) { create(:project, description: 'markdown _rocks_: www.auto.link').decorate }
  let!(:award_type) { create(:award_type, project: project, community_awardable: false, amount: 1, name: 'Code Contribution') }

  before do
    award_type.awards.create_with_quantity(50, issuer: owner, account: authentication.account)
    assign :project, project
    assign :current_account, owner
    assign :award_data, contributions_summary_pie_chart: [
      { net_amount: 50,
        name: 'Tony! Toni! Toné!' }
    ]
    assign :contributors, project.contributors_by_award_amount.page(1)
    allow(view).to receive(:policy).and_return(double('project policy',
      edit?: false,
      show_contributions?: true,
      show_revenue_info?: true))
  end

  describe 'with contributors and revenue shares' do
    before { project.update(payment_type: :revenue_share) }

    it 'shows table with USD' do
      render
      expect(rendered).to have_text('Contributors')
      expect(rendered).to have_selector('td.contributor')
      expect(rendered).to have_selector('td.contributor', text: 'John Doe')
      expect(rendered).to have_selector('td.awards-earned', text: '50')
      expect(rendered).to have_selector('td.paid', text: '$0')
      expect(rendered).to have_selector('td.award-holdings', text: '50')
      expect(rendered).to have_selector('td.holdings-value', text: '$0')
    end

    it 'shows table with Bittoken' do
      project.update(denomination: :BTC)
      render

      expect(rendered).to have_selector('td.paid', text: '฿0')
      expect(rendered).to have_selector('td.holdings-value', text: '฿0')
    end

    it 'shows table with Eth' do
      project.update(denomination: :ETH)
      render

      expect(rendered).to have_selector('td.paid', text: 'Ξ0')
      expect(rendered).to have_selector('td.holdings-value', text: 'Ξ0')
    end
  end

  describe 'with contributors and project tokens' do
    it 'shows table without currency values' do
      render

      expect(rendered).to have_text('Contributors')
      expect(rendered).to have_selector('td.contributor')
      expect(rendered).to have_selector('td.contributor', text: 'John Doe')
      expect(rendered).to have_selector('td.awards-earned', text: '50')
      expect(rendered).to have_selector('td.award-holdings', text: '50')

      expect(rendered).not_to have_selector('td.paid', text: '$0')
      expect(rendered).not_to have_selector('td.holdings-value', text: '$0')
      expect(rendered).not_to have_content('$')

      expect(rendered).not_to have_selector('th', text: /^paid/i)
      expect(rendered).not_to have_selector('th', text: /value/i)
    end
  end

  describe 'without contributors' do
    before do
      assign :award_data, award_amounts: { total_tokens_issued: 0 }, contributions_summary_pie_chart: []
      assign :contributors, Account.none.page(1)
    end

    it 'hides table' do
      render
      expect(rendered).not_to have_selector('td.contributor')
      expect(rendered).not_to have_selector('td.awards-earned')
      expect(rendered).not_to have_selector('td.paid')
      expect(rendered).not_to have_selector('td.award-holdings')
      expect(rendered).not_to have_selector('td.holdings-value')
    end
  end
end
