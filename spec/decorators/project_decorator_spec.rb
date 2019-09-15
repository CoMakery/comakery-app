require 'rails_helper'

describe ProjectDecorator do
  let(:amount_with_24_decimal_precision) { BigDecimal('9.999_999_999_999_999_999_999') }
  let(:project) { (create :project, maximum_tokens: 1000000000).decorate }
  let(:award_type) { create :award_type, project: project }

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
  end

  describe '#outstanding_award_description' do
    specify do
      project.project_token!
      expect(project.outstanding_award_description).to eq('Project Tokens')
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

  describe '#total_awarded_pretty' do
    before do
      create(:award, award_type: award_type, quantity: 1000, amount: 1337, issuer: project.account, account: create(:account))
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
      create(:award, award_type: award_type, amount: 1337, account: account)
      expect(project.total_awarded_to_user(account))
        .to eq('1,337')
    end
  end

  it '#description_text' do
    expect(project.decorate.description_text(12)).to eq 'We are go...'
    expect(project.decorate.description_text(4)).to eq 'W...'
  end

  it '#contributors_by_award_amount' do
    expect(project.contributors_by_award_amount).to eq []
  end

  it 'maximum_tokens_pretty' do
    expect(project.maximum_tokens_pretty).to eq '1,000,000,000'
  end

  it 'format_with_decimal_places' do
    project.token.update decimal_places: 3
    expect(project.format_with_decimal_places(10)).to eq '10.000'
  end

  it 'format_with_decimal_places with no token associated' do
    project.update(token: nil)
    expect(project.format_with_decimal_places(10)).to eq '10'
  end

  describe 'header_props' do
    let!(:project) { create(:project) }
    let!(:award_type) { create(:award_type, project: project, state: :ready) }
    let!(:unlisted_project) { create(:project, visibility: 'public_unlisted') }
    let!(:project_wo_image) { create(:project) }

    it 'includes required data for project header component' do
      props = project.decorate.header_props
      props_unlisted = unlisted_project.decorate.header_props
      project_wo_image.update(panoramic_image_id: nil)
      props_wo_image = project_wo_image.decorate.header_props

      expect(props[:title]).to eq(project.title)
      expect(props[:owner]).to eq(project.legal_project_owner)
      expect(props[:present]).to be_truthy
      expect(props[:show_batches]).to be_truthy
      expect(props[:show_payments]).to be_truthy
      expect(props[:image_url]).to include('image.png')
      expect(props[:admins_url]).to include(project.id.to_s)
      expect(props[:settings_url]).to include(project.id.to_s)
      expect(props[:batches_url]).to include(project.id.to_s)
      expect(props[:contributors_url]).to include(project.id.to_s)
      expect(props[:transfers_url]).to include(project.id.to_s)
      expect(props[:landing_url]).to include(project.id.to_s)
      expect(props_unlisted[:landing_url]).to include(unlisted_project.long_id.to_s)
      expect(props_wo_image[:image_url]).to include('defaul_project')
    end
  end
end
