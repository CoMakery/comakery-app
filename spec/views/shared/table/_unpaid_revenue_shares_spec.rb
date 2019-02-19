require 'rails_helper'

describe 'shared/table/_unpaid_revenue_shares.html.rb' do
  let(:project) { raise 'define let(:project) in your describe block' }
  let(:current_auth) { create :authentication }

  before do
    assign :project, project.decorate
    assign :current_auth, current_auth.decorate
    render
  end

  describe 'project token' do
    let(:project) { create :project, payment_type: :project_token }

    specify { expect(rendered).to eq('') }
  end

  describe 'revenue shares' do
    let(:project) { create :project, token: create(:token, denomination: 'USD'), payment_type: :revenue_share }

    specify do
      expect(rendered).to have_css('.total-awarded', text: '0')
    end

    specify do
      expect(rendered).to have_css('.awards-redeemed', text: '0')
    end

    specify do
      expect(rendered).to have_css('.awards-outstanding', text: '0')
    end
  end
end
