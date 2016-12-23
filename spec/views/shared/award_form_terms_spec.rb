require 'rails_helper'

describe "shared/award_form_terms.html.rb" do

  let(:project) do
    create(
        :project,
        title: 'Mindful Inc',
        royalty_percentage: 8,
        legal_project_owner: "The Legal Owner",
        maximum_coins: 200_000,
        maximum_royalties_per_month: 27_000,
        require_confidentiality: true,
        exclusive_contributions: true,
        denomination: :USD,
        payment_type: :revenue_share,
        license_finalized: true,
        description: 'markdown _rocks_: www.auto.link').decorate
  end

  before do
    assign :project, project
  end

  describe 'with revenue shares' do
    it 'renders all fields for royalty projects when present' do
      render
      expect(rendered).to have_content "Status: These terms are finalized and legally binding."
      expect(rendered).to have_content "Project Name"
      expect(rendered).to have_content "Revenue Reserved To Pay Contributors: 8.0%"
      expect(rendered).to have_content "Maximum Revenue Shares: 200,000"
      expect(rendered).to have_content "Maximum Revenue Shares Awarded Per Month: 27,000"
      expect(rendered).to have_content "Contributions: are exclusive"
      expect(rendered).to have_content "Business Confidentiality: is required"
      expect(rendered).to have_content "Project Confidentiality: is required"
      expect(rendered).to have_selector('.revenue-sharing-only')
    end

    specify do
      project.update!(exclusive_contributions: false)
      render

      expect(rendered).to have_content "Contributions: are not exclusive"
    end

    specify do
      project.update!(license_finalized: false)

      render
      expect(rendered).to have_content "Status: This is a draft of possible project terms that is not legally binding."
    end

    specify do
      project.update!(require_confidentiality: false)
      render
      expect(rendered).to have_content "Business Confidentiality: is not required"
      expect(rendered).to have_content "Project Confidentiality: is not required"
    end

    describe 'currency displayed correctly for' do
      specify do
        project.USD!
        render

        expect(rendered).to have_content /Minimum Revenue.*\$/
        expect(rendered).to have_content /Minimum Payment.*\$/
      end

      specify do
        project.BTC!
        render

        expect(rendered).to have_content /Minimum Revenue.*฿/
        expect(rendered).to have_content /Minimum Payment.*฿/
      end

      specify do
        project.ETH!
        render

        expect(rendered).to have_content /Minimum Revenue.*Ξ/
        expect(rendered).to have_content /Minimum Payment.*Ξ/
      end
    end
  end

  describe 'with project coins' do
    before do
      project.project_coin!
    end

    it 'has legal terms without revenue sharing' do
      render
      expect(rendered).to have_content "Status"
      expect(rendered).to have_content "Project Name"

      expect(rendered).to have_content "Maximum Project Coins"
      expect(rendered).to have_content "Maximum Project Coins Awarded Per Month"
      expect(rendered).to have_content "Contributions"
      expect(rendered).to have_content "Business Confidentiality"
      expect(rendered).to have_content "Project Confidentiality"

      expect(rendered).to_not have_selector('.revenue-sharing-only')
      expect(rendered).to_not have_content "Minimum Revenue"
      expect(rendered).to_not have_content "Minimum Payment"
      expect(rendered).to_not have_content "$"
    end
  end
end
