require 'rails_helper'

describe ProjectDecorator do
  let(:amount_with_24_decimal_precision) { BigDecimal('9.999_999_999_999_999_999_999') }
  let(:project) { (create :project, royalty_percentage: 100).decorate }
  let(:award_type) { create :award_type, project: project }

  describe 'total_revenue_pretty method truncates' do
    let(:project_method) { 'total_revenue' }

    before { allow(project).to receive(project_method).and_return(amount_with_24_decimal_precision) }

    def pretty_method_call
      project.send "#{project_method}_pretty"
    end

    specify do
      project.token.USD!
      expect(pretty_method_call).to eq('$9.99')
    end

    specify do
      project.token.BTC!
      expect(pretty_method_call).to match(/^฿9.9{8}$/)
    end

    specify do
      project.token.ETH!
      expect(pretty_method_call).to match(/^Ξ9.9{18}$/)
    end
  end

  describe 'revenue_per_share_pretty method truncates' do
    let(:project_method) { 'total_revenue_shared' }

    before { allow(project).to receive(project_method).and_return(amount_with_24_decimal_precision) }

    def pretty_method_call
      project.send "#{project_method}_pretty"
    end

    specify do
      project.token.USD!
      expect(pretty_method_call).to eq('$9.99')
    end

    specify do
      project.token.BTC!
      expect(pretty_method_call).to match(/^฿9.9{8}$/)
    end

    specify do
      project.token.ETH!
      expect(pretty_method_call).to match(/^Ξ9.9{18}$/)
    end

    specify do
      expect(project.decorate.revenue_history).to eq []
      expect(project.decorate.payment_history).to eq []
    end
  end

  describe 'revenue_per_share_pretty method truncates' do
    let(:project_method) { 'revenue_per_share' }

    before { allow(project).to receive(project_method).and_return(amount_with_24_decimal_precision) }

    def pretty_method_call
      project.send "#{project_method}_pretty"
    end

    specify do
      project.token.USD!
      expect(pretty_method_call).to match(/^\$9.9{8}$/)
    end

    specify do
      project.token.BTC!
      expect(pretty_method_call).to match(/^฿9.9{8}$/)
    end

    specify do
      project.token.ETH!
      expect(pretty_method_call).to match(/^Ξ9.9{8}$/)
    end
  end

  describe '#description_html' do
    let(:project) do
      create(:project,
        description: 'Hi [google](http://www.google.com)')
        .decorate
    end

    specify do
      expect(project.description_html).to include('Hi <a href="http://www.google.com"')
    end
  end

  describe 'with ethereum contract' do
    let(:project) do
      build(
        :project,
        token: create(
          :token,
          ethereum_contract_address: '0xa234567890b234567890a234567890b234567890',
          symbol: 'TST',
          decimal_places: 2
        )
      ).decorate
    end

    specify do
      expect(project.ethereum_contract_explorer_url)
        .to include("#{Rails.application.config.ethereum_explorer_site}/token/#{project.token.ethereum_contract_address}")
    end
  end

  describe 'with contract_address' do
    let(:project) do
      build(
        :project,
        token: create(
          :token,
          coin_type: 'qrc20',
          blockchain_network: 'qtum_testnet',
          contract_address: 'a234567890b234567890a234567890b234567890'
        )
      ).decorate
    end

    specify do
      expect(project.ethereum_contract_explorer_url)
        .to include(UtilitiesService.get_contract_url(project.token.blockchain_network, project.token.contract_address))
    end
  end

  describe '#status_description' do
    specify do
      project.update license_finalized: true
      expect(project.status_description).to include('finalized and legally binding')
    end

    specify do
      project.update license_finalized: false
      expect(project.status_description).to include('not legally binding')
    end
  end

  describe '#currency_denomination' do
    specify do
      project.token.update denomination: 'USD'
      expect(project.currency_denomination).to eq('$')
    end

    specify do
      project.token.update denomination: 'BTC'
      expect(project.currency_denomination).to eq('฿')
    end

    specify do
      project.token.update denomination: 'ETH'
      expect(project.currency_denomination).to eq('Ξ')
    end
  end

  describe '#payment_description' do
    specify do
      project.project_token!
      expect(project.payment_description).to eq('Project Tokens')
    end

    specify do
      project.revenue_share!
      expect(project.payment_description).to eq('Revenue Shares')
    end
  end

  describe '#outstanding_award_description' do
    specify do
      project.project_token!
      expect(project.outstanding_award_description).to eq('Project Tokens')
    end

    specify do
      project.revenue_share!
      expect(project.outstanding_award_description).to eq('Unpaid Revenue Shares')
    end
  end

  describe 'royalty_percentage_pretty' do
    specify do
      project.royalty_percentage = nil
      expect(project.royalty_percentage_pretty).to eq('0%')
    end

    specify do
      project.royalty_percentage = 10
      expect(project.royalty_percentage_pretty).to eq('10%')
    end

    specify do
      project.royalty_percentage = 10.9
      expect(project.royalty_percentage_pretty).to eq('10.9%')
    end

    specify do
      project.royalty_percentage = BigDecimal('10.999_999_999_999_9')
      expect(project.royalty_percentage_pretty).to eq('10.' + ('9' * 13) + '%')
    end
  end

  describe 'require_confidentiality_text' do
    specify do
      project.require_confidentiality = true
      expect(project.require_confidentiality_text).to eq('is required')
    end

    specify do
      project.require_confidentiality = false
      expect(project.require_confidentiality_text).to eq('is not required')
    end
  end

  describe 'exclusive_contributions_text' do
    specify do
      project.exclusive_contributions = true
      expect(project.exclusive_contributions_text).to eq('are exclusive')
    end

    specify do
      project.exclusive_contributions = false
      expect(project.exclusive_contributions_text).to eq('are not exclusive')
    end
  end

  describe 'total_revenue_pretty' do
    specify do
      project.token.USD!
      expect(project.total_revenue_pretty).to eq('$0.00')
    end

    specify do
      project.token.BTC!
      expect(project.total_revenue_pretty).to eq('฿0.00000000')
    end

    specify do
      project.token.ETH!
      expect(project.total_revenue_pretty).to eq('Ξ0.000000000000000000')
    end
  end

  describe 'total_revenue_shared_pretty' do
    specify do
      project.token.USD!
      expect(project.total_revenue_shared_pretty).to eq('$0.00')
    end

    specify do
      project.token.BTC!
      expect(project.total_revenue_shared_pretty).to eq('฿0.00000000')
    end

    specify do
      project.token.ETH!
      expect(project.total_revenue_shared_pretty).to eq('Ξ0.000000000000000000')
    end
  end

  describe '#total_awarded_pretty' do
    before do
      award_type.awards.create_with_quantity(1_000, issuer: project.account,
                                                    account: create(:account))
    end

    specify { expect(project.total_awarded_pretty).to eq('1,337,000') }
  end

  describe '#total_awards_outstanding' do
    specify do
      expect(project)
        .to receive(:total_awards_outstanding)
        .and_return(1_234_567)

      expect(project.total_awards_outstanding_pretty)
        .to eq('1,234,567')
    end
  end

  describe '#total_awarded' do
    specify do
      expect(project)
        .to receive(:total_awarded)
        .and_return(1_234_567)

      expect(project.total_awarded_pretty)
        .to eq('1,234,567')
    end
  end

  describe '#total_awarded_to_user' do
    specify do
      account = create(:account)
      create(:award, award_type: award_type, account: account)
      expect(project.total_awarded_to_user(account))
        .to eq('1,337')
    end
  end

  describe '#total_awards_redeemed' do
    specify do
      expect(project)
        .to receive(:total_awards_redeemed)
        .and_return(1_234_567)

      expect(project.total_awards_redeemed_pretty)
        .to eq('1,234,567')
    end
  end

  describe '#revenue_per_share' do
    specify do
      project.token.USD!
      expect(project.revenue_per_share_pretty)
        .to eq('$0.00000000')
    end

    specify do
      project.token.BTC!
      expect(project.revenue_per_share_pretty)
        .to eq('฿0.00000000')
    end

    specify do
      project.token.ETH!
      expect(project.revenue_per_share_pretty)
        .to eq('Ξ0.00000000')
    end
  end

  describe '#total_revenue_shared_unpaid' do
    specify do
      expect(project)
        .to receive(:total_revenue_shared_unpaid)
        .and_return(BigDecimal('1234567'))

      expect(project.total_revenue_shared_unpaid_pretty)
        .to eq('$1,234,567.00')
    end

    specify do
      project.token.BTC!
      expect(project)
        .to receive(:total_revenue_shared_unpaid)
        .and_return(BigDecimal('1234567'))

      expect(project.total_revenue_shared_unpaid_pretty)
        .to eq('฿1,234,567.00000000')
    end
  end

  describe '#total_paid_to_contributors' do
    specify do
      expect(project)
        .to receive(:total_paid_to_contributors)
        .and_return(BigDecimal('1234567'))

      expect(project.total_paid_to_contributors_pretty)
        .to eq('$1,234,567.00')
    end

    specify do
      project.token.BTC!
      expect(project)
        .to receive(:total_paid_to_contributors)
        .and_return(BigDecimal('1234567'))

      expect(project.total_paid_to_contributors_pretty)
        .to eq('฿1,234,567.00000000')
    end
  end

  describe '#miniumum_revenue' do
    specify do
      project.token.USD!
      expect(project.minimum_revenue).to eq('$0')
    end

    specify do
      project.token.BTC!
      expect(project.minimum_revenue).to eq('฿0')
    end
  end

  describe '#minimum_payment' do
    specify do
      project.token.USD!
      expect(project.minimum_payment).to eq('$1')
    end

    specify do
      project.token.BTC!
      expect(project.minimum_payment).to eq('฿0.001')
    end

    specify do
      project.token.ETH!
      expect(project.minimum_payment).to eq('Ξ0.1')
    end
  end

  describe '#share_of_revenue_unpaid' do
    before do
      expect(project).to receive(:share_of_revenue_unpaid)
        .and_return(BigDecimal('1234567'))
    end

    specify do
      project.token.USD!

      expect(project.share_of_revenue_unpaid_pretty(1234567))
        .to eq('$1,234,567.00')
    end

    specify do
      project.token.BTC!

      expect(project.share_of_revenue_unpaid_pretty(1234567))
        .to eq('฿1,234,567.00000000')
    end
  end

  describe '#revenue_shareing_end_date_pretty' do
    specify do
      project.revenue_sharing_end_date = nil
      expect(project.revenue_sharing_end_date_pretty).to eq('revenue sharing does not have an end date.')
    end

    specify do
      project.revenue_sharing_end_date = '2123-01-02'
      expect(project.revenue_sharing_end_date_pretty)
        .to eq('January 2, 2123')
    end
  end

  it '#description_text' do
    expect(project.decorate.description_text(12)).to eq 'We are go...'
    expect(project.decorate.description_text(4)).to eq 'W...'
  end

  it '#contributors_by_award_amount' do
    expect(project.contributors_by_award_amount).to eq []
  end

  it 'maximum_royalties_per_month_pretty' do
    expect(project.maximum_royalties_per_month_pretty).to eq '10,000'
  end

  it 'maximum_tokens_pretty' do
    expect(project.maximum_tokens_pretty).to eq '10,000,000'
  end

  it 'format_with_decimal_places' do
    project.token.update decimal_places: 3
    expect(project.format_with_decimal_places(10)).to eq '10.000'
  end
end
