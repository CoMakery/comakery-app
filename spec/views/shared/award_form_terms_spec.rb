require 'rails_helper'

describe 'shared/award_form_terms.html.rb' do
  let(:project) do
    create(
      :project,
      title: 'Mindful Inc',
      royalty_percentage: 8,
      legal_project_owner: 'The Legal Owner',
      maximum_tokens: 200_000,
      maximum_royalties_per_month: 27_000,
      require_confidentiality: true,
      exclusive_contributions: true,
      token: create(:token, denomination: :USD),
      payment_type: :revenue_share,
      license_finalized: false,
      revenue_sharing_end_date: '2050/01/02',
      description: 'markdown _rocks_: www.auto.link'
    ).decorate
  end

  before do
    assign :project, project
  end

  describe 'with revenue shares' do
    it 'renders all fields for royalty projects when present' do
      render
      expect(rendered).to have_content 'Project Name'
      expect(rendered).to have_content 'Revenue Reserved To Pay Contributors: 8%'
      expect(rendered).to have_content 'Maximum Revenue Shares: 200,000'
      expect(rendered).to have_content 'Maximum Revenue Shares Awarded Per Month: 27,000'
      expect(rendered).to have_content 'Contributions: are exclusive'
      expect(rendered).to have_content 'Status: This is a draft of possible project terms that is not legally binding.'
      expect(rendered).to have_content 'Business Confidentiality: is required'
      expect(rendered).to have_content 'Project Confidentiality: is required'
      expect(rendered).to have_content 'Revenue Sharing End Date: January 2, 2050'
      expect(rendered).to have_selector('.revenue-sharing-only')
    end

    it 'when revenue sharing end date is nil indicate there is no end date' do
      project.update!(revenue_sharing_end_date: nil)
      render

      expect(rendered).to have_content 'Revenue Sharing End Date: revenue sharing does not have an end date.'
    end

    specify do
      project.update!(exclusive_contributions: false)
      render

      expect(rendered).to have_content 'Contributions: are not exclusive'
    end

    specify do
      project.update!(license_finalized: true)

      render
      expect(rendered).to have_content 'Status: These terms are finalized and legally binding.'
    end

    specify do
      project.update!(require_confidentiality: false)
      render
      expect(rendered).to have_content 'Business Confidentiality: is not required'
      expect(rendered).to have_content 'Project Confidentiality: is not required'
    end

    describe 'currency displayed correctly for' do
      specify do
        project.token.USD!
        render

        expect(rendered).to have_content /Minimum Revenue.*\$/
        expect(rendered).to have_content /Minimum Payment.*\$/
      end

      specify do
        project.token.BTC!
        render

        expect(rendered).to have_content /Minimum Revenue.*฿/
        expect(rendered).to have_content /Minimum Payment.*฿/
      end

      specify do
        project.token.ETH!
        render

        expect(rendered).to have_content /Minimum Revenue.*Ξ/
        expect(rendered).to have_content /Minimum Payment.*Ξ/
      end
    end
  end

  describe 'with project tokens' do
    before do
      project.project_token!
    end

    it 'has legal terms without revenue sharing' do
      render
      expect(rendered).to have_content 'Status'
      expect(rendered).to have_content 'Project Name'

      expect(rendered).to have_content 'Maximum Project Tokens'
      expect(rendered).to have_content 'Maximum Project Tokens Awarded Per Month'
      expect(rendered).to have_content 'Contributions'
      expect(rendered).to have_content 'Business Confidentiality'
      expect(rendered).to have_content 'Project Confidentiality'

      expect(rendered).not_to have_selector('.revenue-sharing-only')
      expect(rendered).not_to have_content 'Minimum Revenue'
      expect(rendered).not_to have_content 'Minimum Payment'
      expect(rendered).not_to have_content '$'
      expect(rendered).not_to have_content 'Revenue Sharing End Date'
    end
  end
end
