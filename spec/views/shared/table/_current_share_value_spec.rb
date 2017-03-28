require 'rails_helper'

describe "shared/table/_current_share_value.html.rb" do
  let(:project) { raise "define let(:project) in your describe block" }

  before do
    assign :project, project.decorate
    render
  end

  describe 'project coin' do
    let(:project) { create :project, payment_type: :project_coin }

    specify { expect(rendered).to eq("") }
  end

  describe 'USD' do
    let(:project) { create :project, denomination: 'USD' }

    specify do
      expect(rendered).to have_css('.total-revenue-unpaid', text: '$0.00')
    end

    specify do
      expect(rendered).to have_css('.unpaid-revenue-shares', text: '0')
    end

    specify do
      expect(rendered).to have_css('.revenue-per-share', text: '$0.00000000')
    end
  end

  describe 'BTC' do
    let(:project) { create :project, denomination: 'BTC' }

    specify do
      expect(rendered).to have_css('.total-revenue-unpaid', text: '฿0.00')
    end

    specify do
      expect(rendered).to have_css('.revenue-per-share', text: '฿0.00000000')
    end
  end

  describe 'ETH' do
    let(:project) { create :project, denomination: 'ETH' }

    specify do
      expect(rendered).to have_css('.total-revenue-unpaid', text: 'Ξ0.00')
    end

    specify do
      expect(rendered).to have_css('.revenue-per-share', text: 'Ξ0.00000000')
    end
  end
end