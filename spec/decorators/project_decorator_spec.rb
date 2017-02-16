require 'rails_helper'

describe ProjectDecorator do
  let(:amount_with_24_decimal_precision) { BigDecimal('9.999_999_999_999_999_999_999') }
  let(:project) { (create :project, royalty_percentage: 100).decorate }

  describe "total_revenue_pretty method truncates" do
    let(:project_method) { 'total_revenue' }

    before { allow(project).to receive(project_method).and_return(amount_with_24_decimal_precision) }

    def pretty_method_call
      project.send "#{project_method}_pretty"
    end

    specify do
      project.USD!
      expect(pretty_method_call).to eq("$9.99")
    end

    specify do
      project.BTC!
      expect(pretty_method_call).to match(/^฿9.9{8}$/)
    end

    specify do
      project.ETH!
      expect(pretty_method_call).to match(/^Ξ9.9{18}$/)
    end
  end

  describe "revenue_per_share_pretty method truncates" do
    let(:project_method) { 'total_revenue_shared' }

    before { allow(project).to receive(project_method).and_return(amount_with_24_decimal_precision) }

    def pretty_method_call
      project.send "#{project_method}_pretty"
    end

    specify do
      project.USD!
      expect(pretty_method_call).to eq("$9.99")
    end

    specify do
      project.BTC!
      expect(pretty_method_call).to match(/^฿9.9{8}$/)
    end

    specify do
      project.ETH!
      expect(pretty_method_call).to match(/^Ξ9.9{18}$/)
    end
  end

  describe "revenue_per_share_pretty method truncates" do
    let(:project_method) { 'revenue_per_share' }

    before { allow(project).to receive(project_method).and_return(amount_with_24_decimal_precision) }

    def pretty_method_call
      project.send "#{project_method}_pretty"
    end

    specify do
      project.USD!
      expect(pretty_method_call).to eq("$9.9999")
    end

    specify do
      project.BTC!
      expect(pretty_method_call).to match(/^฿9.9{8}$/)
    end

    specify do
      project.ETH!
      expect(pretty_method_call).to match(/^Ξ9.9{18}$/)
    end
  end
end