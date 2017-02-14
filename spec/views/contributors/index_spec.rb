require 'rails_helper'

describe "contributors/index.html.rb" do

  let(:project) { create(:project, description: 'markdown _rocks_: www.auto.link').decorate }

  before do
    assign :project, project
    assign :award_data, {award_amounts: {total_coins_issued: 0},
                         contributions_summary: [
                             {avatar: 'http://google.com',
                              earned: 10,
                              name: "Tony! Toni! Toné!"}
                         ]
    }

    allow(view).to receive(:policy).and_return(double("project policy",
                                                      edit?: false,
                                                      show_contributions?: true,
                                                      show_revenue_info?: true))
  end

  describe "with contributors and revenue shares" do
    it "shows table with USD" do
      render
      expect(rendered).to have_text("Contributors")
      expect(rendered).to have_selector('td.contributor')
      expect(rendered).to have_selector('td.contributor', text: "Tony! Toni! Toné!")
      expect(rendered).to have_selector('td.awards-earned', text: "10")
      expect(rendered).to have_selector('td.paid', text: "$0")
      expect(rendered).to have_selector('td.award-holdings', text: "10")
      expect(rendered).to have_selector('td.holdings-value', text: "$0")
    end

    it "shows table with Bitcoin" do
      project.update(denomination: :BTC)
      render

      expect(rendered).to have_selector('td.paid', text: "฿0")
      expect(rendered).to have_selector('td.holdings-value', text: "฿0")
    end

    it "shows table with Eth" do
      project.update(denomination: :ETH)
      render

      expect(rendered).to have_selector('td.paid', text: "Ξ0")
      expect(rendered).to have_selector('td.holdings-value', text: "Ξ0")
    end
  end

  describe "with contributors and project coins" do
    it "shows table without currency values" do
      project.update(payment_type: :project_coin)
      render

      expect(rendered).to have_text("Contributors")
      expect(rendered).to have_selector('td.contributor')
      expect(rendered).to have_selector('td.contributor', text: "Tony! Toni! Toné!")
      expect(rendered).to have_selector('td.awards-earned', text: "10")
      expect(rendered).to have_selector('td.award-holdings', text: "10")

      expect(rendered).to_not have_selector('td.paid', text: "$0")
      expect(rendered).to_not have_selector('td.holdings-value', text: "$0")
      expect(rendered).to_not have_content("$")

      expect(rendered).to_not have_selector('th', text: /paid/i)
      expect(rendered).to_not have_selector('th', text: /value/i)
    end
  end

  describe "without contributors" do
    before do
      assign :award_data, {award_amounts: {total_coins_issued: 0}, contributions_summary: []}
    end

    it "hides table" do
      render
      expect(rendered).to_not have_selector('td.contributor')
      expect(rendered).to_not have_selector('td.awards-earned')
      expect(rendered).to_not have_selector('td.paid')
      expect(rendered).to_not have_selector('td.award-holdings')
      expect(rendered).to_not have_selector('td.holdings-value')
    end
  end
end
