require 'rails_helper'

describe 'shared/table/_unpaid_pool.html.rb' do
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

  describe 'USD' do
    let(:project) { create :project, denomination: 'USD', payment_type: :revenue_share }

    specify do
      expect(rendered).to have_css('.total-revenue-shared', text: '$0.00')
    end

    specify do
      expect(rendered).to have_css('.total-paid-to-contributors', text: '$0.00')
    end

    specify do
      expect(rendered).to have_css('.revenue-shared-unpaid', text: '$0.00')
    end
  end

  describe 'BTC' do
    let(:project) { create :project, denomination: 'BTC', payment_type: :revenue_share }

    specify do
      expect(rendered).to have_css('.total-revenue-shared', text: '฿0.00')
    end

    specify do
      expect(rendered).to have_css('.total-paid-to-contributors', text: '฿0.00')
    end

    specify do
      expect(rendered).to have_css('.revenue-shared-unpaid', text: '฿0.00')
    end
  end
end
