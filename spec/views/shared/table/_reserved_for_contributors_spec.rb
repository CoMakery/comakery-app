require 'rails_helper'

describe "shared/table/_reserved_for_contributors.html.rb" do
  let(:project) { raise "define let(:project) in your describe block" }
  let(:current_auth) { create :authentication }

  before do
    assign :project, project.decorate
    assign :current_auth, current_auth.decorate
    render
  end

  describe 'project coin' do
    let(:project) { create :project, payment_type: :project_coin }

    specify { expect(rendered).to eq("") }
  end

  describe 'USD' do
    let(:project) { create :project, denomination: 'USD' }

    specify do
      expect(rendered).to have_css('.total-revenue-shared', text: '$0.00')
    end

    specify do
      expect(rendered).to have_css('.total-revenue', text: '$0.00')
    end

    specify do
      expect(rendered).to have_css('.royalty-percentage', text: '5.9%')
    end
  end

  describe 'BTC' do
    let(:project) { create :project, denomination: 'BTC' }

    specify do
      expect(rendered).to have_css('.total-revenue-shared', text: '฿0.00')
    end

    specify do
      expect(rendered).to have_css('.total-revenue', text: '฿0.00')
    end
  end
end