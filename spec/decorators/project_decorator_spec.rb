require 'rails_helper'

describe ProjectDecorator do
  let(:amount_with_24_decimal_precision) { BigDecimal('9.999_999_999_999_999_999_999') }
  let(:token) { FactoryBot.create :token, decimal_places: 8 }
  let(:project) do
    FactoryBot.create(:project, maximum_tokens: 1_000_000_000, token: token).decorate
  end
  let(:award_type) { create :award_type, project: project }

  describe '#description_html' do
    subject(:description_html) { project.decorate.description_html }

    let(:project) do
      FactoryBot.build_stubbed :project, description: 'Hi [google](http://www.google.com)'
    end

    it 'should return correct description html' do
      expect(description_html).to include('Hi <a href="http://www.google.com"')
    end
  end

  describe '#hot_wallet_address' do
    subject(:hot_wallet_address) { project.decorate.hot_wallet_address }

    let(:hot_wallet) { FactoryBot.build_stubbed :wallet }

    context 'when project with hot wallet' do
      let(:project) { FactoryBot.build_stubbed :project, hot_wallet: hot_wallet }

      it 'should return hot wallet address' do
        expect(hot_wallet_address).to eq hot_wallet.address
      end
    end

    context 'when project without hot wallet' do
      let(:project) { FactoryBot.build_stubbed :project, hot_wallet: nil }

      it 'should return nil' do
        expect(hot_wallet_address).to eq nil
      end
    end
  end

  describe '#description_text_truncated' do
    subject(:description_text_truncated) { project.decorate.description_text_truncated }

    let(:project) do
      FactoryBot.build_stubbed(:project, description: '[Hola](http://google.com) ' + 'a' * 1000)
    end

    specify do
      length_including_dots = 500
      expect(project.decorate.description_text_truncated(500).length).to eq(length_including_dots)
    end

    it 'ends with "..."' do
      last_char = description_text_truncated.length
      start_of_end = last_char - 4
      expect(description_text_truncated[start_of_end, last_char]).to eq('a...')
    end

    it 'does not include html' do
      expect(description_text_truncated).not_to include("<a href='http://google.com'")
      expect(description_text_truncated).to include('Hola')
    end

    it 'can pass in a max length' do
      expect(project.decorate.description_text_truncated(8)).to eq('Hola ...')
    end

    it 'can use a length longer than the string length' do
      project = FactoryBot.build_stubbed(:project, description: 'hola')
      expect(project.decorate.description_text_truncated(100)).to eq('hola')
    end
  end

  describe '#team_size' do
    subject(:team_size) { project.decorate.team_size }

    let(:admin_account) { FactoryBot.create(:account) }
    let(:project) { FactoryBot.create(:project, account: admin_account) }
    let(:other_roles_number) { (1..4).to_a.sample }
    let!(:project_roles_with_account) do
      FactoryBot.create_list(:project_role, other_roles_number, project: project)
    end

    it 'should return number of accounts assigned to the project' do
      expect(team_size).to eq other_roles_number + 1 # other roles number + admin account
    end
  end

  describe '#percent_awarded_pretty' do
    subject(:percent_awarded_pretty) { project.decorate.percent_awarded_pretty }

    let(:project) { FactoryBot.build_stubbed :project, maximum_tokens: 100 }

    before { allow(project).to receive(:total_awarded).and_return(30) }

    it 'should return awarded percent formatted value' do
      expect(percent_awarded_pretty).to eq '30.000%'
    end
  end

  describe '#minimum_payment' do
    subject(:minimum_payment) { project.decorate.minimum_payment }

    let(:project) { FactoryBot.build_stubbed(:project, token: token) }

    shared_context 'return formatted minimum payment' do |denomination, expected_result|
      context "when token denomination is #{denomination}" do
        let(:token) { FactoryBot.build_stubbed(:token, denomination: denomination) }

        it 'should return correctly formatted minimum payment' do
          expect(minimum_payment).to eq expected_result
        end
      end
    end

    it_behaves_like 'return formatted minimum payment', :ETH, 'Ξ0.1'
    it_behaves_like 'return formatted minimum payment', :BTC, '฿0.001'
    it_behaves_like 'return formatted minimum payment', :USD, '$1'
  end

  describe '#tokens_awarded_with_symbol' do
    subject(:tokens_awarded_with_symbol) { project.decorate.tokens_awarded_with_symbol }

    let(:project) { FactoryBot.build_stubbed(:project, token: token) }

    context 'when token symbol is present' do
      let(:token) { FactoryBot.build_stubbed(:token, symbol: 'BTC') }

      it 'should return correct string' do
        expect(tokens_awarded_with_symbol).to eq 'BTC Tokens Awarded'
      end
    end

    context 'when token symbol is not present' do
      let(:token) { FactoryBot.build_stubbed(:token, symbol: nil) }

      it 'should return correct string' do
        expect(tokens_awarded_with_symbol).to eq 'Tokens Awarded'
      end
    end
  end

  describe '#send_coins?' do
    subject(:send_coins) { project.decorate.send_coins? }

    let(:project) { FactoryBot.build_stubbed(:project, token: token) }

    context 'when token is present' do
      %i[eth btc ada qtum eos xtz].each do |token_type|
        context "when token type is #{token_type}" do
          let(:token) { FactoryBot.build_stubbed(:token, _token_type: token_type) }

          it 'should return true' do
            expect(send_coins).to eq true
          end
        end
      end

      %i[
        qrc20 dag erc20 comakery_security_token asa algo
        algorand_security_token token_release_schedule
      ].each do |token_type|
        context "when token type is #{token_type}" do
          let(:token) { FactoryBot.build_stubbed(:token, _token_type: token_type) }

          it 'should return false' do
            expect(send_coins).to eq false
          end
        end
      end
    end

    context 'when token is not present' do
      let(:token) { nil }

      it 'should return false' do
        expect(send_coins).to eq false
      end
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

    specify { expect(project.total_awarded_pretty).to eq('1,337,000.00000000') }
  end

  describe '#total_awarded' do
    specify do
      expect(project)
        .to receive(:total_awarded)
        .and_return(1_234_567)

      expect(project.total_awarded_pretty)
        .to eq('1,234,567.00000000')
    end
  end

  describe '#total_awarded_to_user' do
    specify do
      account = create(:account)
      create(:award, award_type: award_type, amount: 1337, account: account)
      expect(project.total_awarded_to_user(account))
        .to eq('1,337.00000000')
    end
  end

  it '#contributors_by_award_amount' do
    expect(project.contributors_by_award_amount).to eq []
  end

  describe '#maximum_tokens_pretty' do
    subject(:maximum_tokens_pretty) { project.decorate.maximum_tokens_pretty }

    context 'when project with token' do
      let(:project) do
        FactoryBot.build_stubbed(:project, maximum_tokens: 1_000_000_000, token: token)
      end

      context 'when token has decimal places specified' do
        let(:token) { FactoryBot.create :token, decimal_places: 8 }

        it 'should return formatted maximum tokens value' do
          expect(maximum_tokens_pretty).to eq '1,000,000,000.00000000'
        end
      end

      context 'when token does not have decimal places specified' do
        context 'when token type decimal value is 6' do
          let(:token) { FactoryBot.create :token, _token_type: :algo, decimal_places: nil }

          it 'should return formatted maximum tokens value based on token type' do
            expect(maximum_tokens_pretty).to eq '1,000,000,000.000000'
          end
        end

        context 'when token type decimal value is 18' do
          let(:token) { FactoryBot.create :token, _token_type: :eos, decimal_places: nil }

          it 'should return formatted maximum tokens value based on token type' do
            expect(maximum_tokens_pretty).to eq '1,000,000,000.000000000000000000'
          end
        end
      end

      context 'when token has zero decimal places specified' do
        let(:token) { FactoryBot.create :token, decimal_places: 0 }

        it 'should return formatted maximum tokens value' do
          expect(maximum_tokens_pretty).to eq '1,000,000,000'
        end
      end
    end

    context 'when project without token' do
      let(:project) do
        FactoryBot.build_stubbed(:project, maximum_tokens: 1_000_000_000, token: nil)
      end

      it 'should return formatted maximum tokens value' do
        expect(maximum_tokens_pretty).to eq '1,000,000,000'
      end
    end
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
    let!(:award_type) { create(:award_type, project: project, state: 'public') }
    let!(:unlisted_project) { create(:project, visibility: 'public_unlisted') }
    let!(:project_wo_image) { create(:project) }
    let!(:project_comakery_token) { create(:project, token: create(:token, _token_type: :comakery_security_token, contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten)) }

    it 'includes required data for project header component' do
      props = project.decorate.header_props(project.account)
      props_unlisted = unlisted_project.decorate.header_props(project.account)
      project_wo_image.update(panoramic_image: nil)
      props_wo_image = project_wo_image.decorate.header_props(project.account)
      props_w_comakery = project_comakery_token.decorate.header_props(project.account)

      expect(props[:title]).to eq(project.title)
      expect(props[:present]).to be_truthy
      expect(props[:show_batches]).to be_truthy
      expect(props[:show_contributions]).to be_truthy
      expect(props[:owner]).to be_truthy
      expect(props[:observer]).to be_falsey
      expect(props[:interested]).to be_falsey
      expect(props[:supports_transfer_rules]).to be_falsey
      expect(props_w_comakery[:supports_transfer_rules]).to be_truthy
      expect(props[:image_url]).to include('image.png')
      expect(props[:access_url]).to include(project.id.to_s)
      expect(props[:settings_url]).to include(project.id.to_s)
      expect(props[:batches_url]).to include(project.id.to_s)
      expect(props[:transfers_url]).to include(project.id.to_s)
      expect(props[:accounts_url]).to include(project.id.to_s)
      expect(props[:transfer_rules_url]).to include(project.id.to_s)
      expect(props[:landing_url]).to include(project.id.to_s)
      expect(props_unlisted[:landing_url]).to include(unlisted_project.long_id.to_s)
      expect(props_wo_image[:image_url]).to include('default_project')
    end
  end

  describe 'token_props' do
    context 'when token present' do
      let!(:project_comakery_token) do
        create(:project,
               token: create(:token, _token_type: :comakery_security_token,
                                     contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten))
      end

      let!(:token) { project_comakery_token.token }

      subject(:props) { project_comakery_token.decorate.token_props }

      it 'returns token data' do
        expect(props[:token][:name]).to eq(token.name)
        expect(props[:token][:symbol]).to eq(token.symbol)
        expect(props[:token][:network]).to eq(token.blockchain.name)
        expect(props[:token][:address]).to include(token.contract_address.first(5))
        expect(props[:token][:address_url]).to include(token.contract_address)
        expect(props[:token][:logo_url]).to include('dummy_image.png')
      end
    end

    context 'when token is nil' do
      let!(:project) { create(:project, token: nil) }

      subject(:props) { project.decorate.token_props }

      it { expect(props).to be_empty }
    end
  end

  describe 'step_for_amount_input' do
    let(:token) { create(:token, decimal_places: 2) }
    let(:project) { create(:project, token: token) }

    it 'returns minimal step for amount input field based on decimal places of token' do
      expect(project.decorate.step_for_amount_input).to eq(0.01)
    end

    it 'returns 1 as a step for amount input field when token is not present' do
      project.update(token: nil)
      project.reload

      expect(project.decorate.step_for_amount_input).to eq(1)
    end
  end

  describe 'step_for_quantity_input' do
    let(:token) { create(:token, decimal_places: 2) }
    let(:project) { create(:project, token: token) }

    it 'returns 0.1 as a step for amount input field' do
      expect(project.decorate.step_for_quantity_input).to eq(0.1)
    end

    it 'returns 1 as a step for amount input field when token is not present' do
      project.update(token: nil)
      project.reload

      expect(project.decorate.step_for_quantity_input).to eq(1)
    end
  end

  describe 'image_url' do
    let!(:project) { create :project }

    it 'returns image_url if present' do
      expect(project.decorate.image_url).to include('dummy_image.png')
    end

    it 'returns default image' do
      project.update(square_image: nil)
      expect(project.reload.decorate.image_url).to include('default_project')
    end
  end

  describe 'transfers_stacked_chart' do
    let!(:project) { create(:project, token: create(:token, contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', _token_type: :comakery_security_token, _blockchain: :ethereum_ropsten)) }

    before do
      create(:award, amount: 1, transfer_type: project.transfer_types.find_by(name: 'mint'), award_type: create(:award_type, project: project))
      create(:award, amount: 2, transfer_type: project.transfer_types.find_by(name: 'mint'), award_type: create(:award_type, project: project))
      create(:award, amount: 5, transfer_type: project.transfer_types.find_by(name: 'burn'), award_type: create(:award_type, project: project))
    end

    it 'sums awards by timeframe' do
      r = project.decorate.transfers_stacked_chart_day(project.awards.completed)
      expect(r.last['mint']).to eq(3)
      expect(r.last['burn']).to eq(5)
    end

    it 'sets defaults' do
      r = project.decorate.transfers_stacked_chart_day(project.awards.completed)
      expect(r.last['earned']).to eq(0)
    end
  end

  describe 'transfers_donut_chart' do
    let!(:project) { create(:project, token: create(:token, contract_address: '0x8023214bf21b1467be550d9b889eca672355c005', _token_type: :comakery_security_token, _blockchain: :ethereum_ropsten)) }

    before do
      create(:award, amount: 1, transfer_type: project.transfer_types.find_by(name: 'mint'), award_type: create(:award_type, project: project))
      create(:award, amount: 2, transfer_type: project.transfer_types.find_by(name: 'mint'), award_type: create(:award_type, project: project))
      create(:award, amount: 5, transfer_type: project.transfer_types.find_by(name: 'burn'), award_type: create(:award_type, project: project))
    end

    it 'sums awards by type' do
      r = project.decorate.transfers_donut_chart(project.awards.completed)
      expect(r.find { |x| x[:name] == 'mint' }[:value]).to eq(3)
      expect(r.find { |x| x[:name] == 'burn' }[:value]).to eq(5)
    end

    it 'sets defaults' do
      r = project.decorate.transfers_donut_chart(project.awards.completed)
      expect(r.find { |x| x[:name] == 'earned' }[:value]).to eq(0)
    end
  end

  describe 'ratio_pretty' do
    context 'when total is zero' do
      it 'returns 100 %' do
        expect(project.ratio_pretty(1, 0)).to eq('100 %')
      end
    end

    context 'when ratio is zero' do
      it 'returns < 1 %' do
        expect(project.ratio_pretty(0, 1)).to eq('< 1 %')
      end
    end

    context 'when ratio is 100' do
      it 'returns 100 %' do
        expect(project.ratio_pretty(1, 1)).to eq('100 %')
      end
    end

    it 'returns ratio' do
      expect(project.ratio_pretty(1, 2)).to eq('≈ 50 %')
    end
  end

  describe '#team_top' do
    subject(:team_top) { project.decorate.team_top }

    let(:mission) { FactoryBot.create(:mission) }
    let!(:main_account) { FactoryBot.create :account }
    let!(:project) { FactoryBot.create(:project, account: main_account) }

    shared_context 'with admins' do
      let(:admin1) { FactoryBot.create :account }
      let!(:admin_role1) do
        FactoryBot.create :project_role, role: :admin, account: admin1, project: project
      end

      let(:admin2) { FactoryBot.create :account }
      let!(:admin_role2) do
        FactoryBot.create :project_role, role: :admin, account: admin2, project: project
      end

      let(:admin3) { FactoryBot.create :account }
      let!(:admin_role3) do
        FactoryBot.create :project_role, role: :admin, account: admin3, project: project
      end

      let(:admin4) { FactoryBot.create :account }
      let!(:admin_role4) do
        FactoryBot.create :project_role, role: :admin, account: admin4, project: project
      end

      let(:admin5) { FactoryBot.create :account }
      let!(:admin_role5) do
        FactoryBot.create :project_role, role: :admin, account: admin5, project: project
      end
    end

    shared_context 'with regular accounts' do
      let(:account1) { FactoryBot.create :account }
      let!(:account_role1) do
        FactoryBot.create :project_role, role: :observer, account: account1, project: project
      end

      let(:account2) { FactoryBot.create :account }
      let!(:account_role2) do
        FactoryBot.create :project_role, role: :interested, account: account2, project: project
      end

      let(:account3) { FactoryBot.create :account }
      let!(:account_role3) do
        FactoryBot.create :project_role, role: :observer, account: account3, project: project
      end

      let(:account4) { FactoryBot.create :account }
      let!(:account_role4) do
        FactoryBot.create :project_role, role: :interested, account: account4, project: project
      end

      let(:account5) { FactoryBot.create :account }
      let!(:account_role5) do
        FactoryBot.create :project_role, role: :observer, account: account5, project: project
      end
    end

    shared_context 'with top contributors' do
      let(:top_contributor1) { FactoryBot.create :account }
      let(:top_contributor2) { FactoryBot.create :account }
      let(:top_contributor3) { FactoryBot.create :account }
      let(:top_contributor4) { FactoryBot.create :account }
      let(:top_contributor5) { FactoryBot.create :account }
      let(:top_contributor_ids) do
        [
          top_contributor1.id, top_contributor2.id, top_contributor3.id, top_contributor4.id,
          top_contributor5.id
        ]
      end
      let(:top_contributors) { Account.where(id: top_contributor_ids).order('id ASC') }

      before { allow(project).to receive(:top_contributors).and_return(top_contributors) }
    end

    context 'when only main account' do
      it 'should return correct team top' do
        expect(team_top).to eq [main_account]
      end
    end

    context 'when main account and admins' do
      include_context 'with admins'

      it 'should return correct team top' do
        expect(team_top).to eq [main_account, admin1, admin2, admin3, admin4, admin5]
      end
    end

    context 'when main account and regular accounts' do
      include_context 'with regular accounts'

      it 'should return correct team top' do
        expect(team_top).to eq [main_account, account1, account2, account3, account4, account5]
      end
    end

    context 'when main account and top contributors' do
      include_context 'with top contributors'

      it 'should return correct team top' do
        expect(team_top).to eq [
          main_account, top_contributor1, top_contributor2, top_contributor3, top_contributor4,
          top_contributor5
        ]
      end
    end

    context 'when main account and admins and regular accounts' do
      include_context 'with admins'
      include_context 'with regular accounts'

      it 'should return correct team top' do
        expect(team_top).to eq [
          main_account, admin1, admin2, admin3, admin4, admin5, account1, account2
        ]
      end
    end

    context 'when main account and admins and top contributors' do
      include_context 'with admins'
      include_context 'with top contributors'

      it 'should return correct team top' do
        expect(team_top).to eq [
          main_account, admin1, admin2, admin3,
          top_contributor1, top_contributor2, top_contributor3, top_contributor4
        ]
      end
    end

    context 'when main account and regular accounts and top contributors' do
      include_context 'with regular accounts'
      include_context 'with top contributors'

      it 'should return correct team top' do
        expect(team_top).to eq [
          main_account, top_contributor1, top_contributor2, top_contributor3,
          top_contributor4, top_contributor5, account1, account2
        ]
      end
    end

    context 'when all sorts of users' do
      include_context 'with admins'
      include_context 'with regular accounts'
      include_context 'with top contributors'

      it 'should return correct team top' do
        expect(team_top).to eq [
          main_account, admin1, admin2, admin3,
          top_contributor1, top_contributor2, top_contributor3, top_contributor4
        ]
      end
    end
  end

  describe '#transfers_chart_colors' do
    subject(:transfers_chart_colors) { project.decorate.transfers_chart_colors }

    let(:project) { FactoryBot.create(:project) }
    let!(:mint_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'mint') }
    let!(:burn_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'burn') }

    before do
      allow(project).to receive(:transfer_types).and_wrap_original do |method|
        method.call.order(:name)
      end
    end

    it 'should return hash with color mappings' do
      expect(transfers_chart_colors).to match_array 'bought' => '#73C30E',
                                                    'burn' => '#7B00D7',
                                                    'earned' => '#0884FF',
                                                    'mint' => '#E5004F'
    end
  end

  describe '#transfers_chart_colors_objects' do
    subject(:transfers_chart_colors_objects) { project.decorate.transfers_chart_colors_objects }

    let(:project) { FactoryBot.create(:project) }
    let(:earned_transfer_type) { TransferType.find_by(name: 'earned') }
    let(:bought_transfer_type) { TransferType.find_by(name: 'bought') }
    let!(:mint_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'mint') }
    let!(:burn_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'burn') }

    before do
      allow(project).to receive(:transfer_types).and_wrap_original do |method|
        method.call.order(:name)
      end
    end

    it 'should return hash with transfer type objects and color mappings' do
      expect(transfers_chart_colors_objects).to match_array bought_transfer_type => '#73C30E',
                                                            burn_transfer_type => '#7B00D7',
                                                            earned_transfer_type => '#0884FF',
                                                            mint_transfer_type => '#E5004F'
    end
  end

  describe '#transfers_stacked_chart_week' do
    let(:now) { Time.zone.local(2021, 6, 21) }
    let(:project) { FactoryBot.create(:project) }
    let(:earned_transfer_type) { TransferType.find_by(name: 'earned') }
    let(:bought_transfer_type) { TransferType.find_by(name: 'bought') }
    let!(:mint_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'mint') }
    let!(:burn_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'burn') }

    before { Timecop.freeze(now) }

    after { Timecop.return }

    context 'when no awards' do
      let(:transfers) { Award.none }

      shared_examples 'return data for chart with zeros' do
        it do
          expect(transfers_stacked_chart_week).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 3, 29).to_i, :timeframe => "29\tMar"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 5).to_i, :timeframe => "05\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 12).to_i, :timeframe => "12\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 19).to_i, :timeframe => "19\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 26).to_i, :timeframe => "26\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 3).to_i, :timeframe => "03\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 10).to_i, :timeframe => "10\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 17).to_i, :timeframe => "17\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 24).to_i, :timeframe => "24\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 31).to_i, :timeframe => "31\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 7).to_i, :timeframe => "07\tJun"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 14).to_i, :timeframe => "14\tJun"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 21).to_i, :timeframe => "21\tJun"
            }
          ]
        end
      end

      context 'when regular' do
        subject(:transfers_stacked_chart_week) do
          project.decorate.transfers_stacked_chart_week(transfers)
        end

        it_behaves_like 'return data for chart with zeros'
      end

      context 'when negative' do
        subject(:transfers_stacked_chart_week) do
          project.decorate.transfers_stacked_chart_week(transfers, negative: true)
        end

        it_behaves_like 'return data for chart with zeros'
      end
    end

    context 'when with awards' do
      let(:award_type) { FactoryBot.create(:award_type, project: project) }
      let!(:award1) do
        FactoryBot.create :award, project: project, transfer_type: earned_transfer_type,
                                  created_at: Time.zone.local(2021, 5, 24), amount: 5, quantity: 2,
                                  award_type: award_type
      end
      let!(:award2) do
        FactoryBot.create :award, project: project, transfer_type: burn_transfer_type,
                                  created_at: Time.zone.local(2021, 6, 2), amount: 13,
                                  award_type: award_type
      end
      let!(:award3) do
        FactoryBot.create :award, project: project, transfer_type: burn_transfer_type,
                                  created_at: Time.zone.local(2021, 4, 15), amount: 3,
                                  award_type: award_type
      end
      let!(:award4) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2021, 4, 2), amount: 7,
                                  award_type: award_type
      end
      let!(:award5) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2021, 5, 31), amount: 5
      end
      let!(:award6) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2021, 3, 25), amount: 45
      end

      let(:other_project) { FactoryBot.create :project }
      let!(:other_transfer_type) do
        FactoryBot.create(:transfer_type, project: other_project, name: 'mint')
      end
      let!(:other_award1) do
        FactoryBot.create :award, project: other_project, transfer_type: other_transfer_type,
                                  created_at: Time.zone.local(2021, 2, 15), amount: 7
      end

      let(:transfers) { project.awards }

      context 'when regular' do
        subject(:transfers_stacked_chart_week) do
          project.decorate.transfers_stacked_chart_week(transfers)
        end

        it 'should return correct chart data' do
          expect(transfers_stacked_chart_week).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 7, 'burn' => 0,
              :i => Time.zone.local(2021, 3, 29).to_i, :timeframe => "29\tMar"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 5).to_i, :timeframe => "05\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 3,
              :i => Time.zone.local(2021, 4, 12).to_i, :timeframe => "12\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 19).to_i, :timeframe => "19\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 26).to_i, :timeframe => "26\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 3).to_i, :timeframe => "03\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 10).to_i, :timeframe => "10\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 17).to_i, :timeframe => "17\tMay"
            },
            {
              'bought' => 0, 'earned' => 10, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 24).to_i, :timeframe => "24\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 5, 'burn' => 13,
              :i => Time.zone.local(2021, 5, 31).to_i, :timeframe => "31\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 7).to_i, :timeframe => "07\tJun"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 14).to_i, :timeframe => "14\tJun"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 21).to_i, :timeframe => "21\tJun"
            }
          ]
        end
      end

      context 'when negative' do
        subject(:transfers_stacked_chart_week) do
          project.decorate.transfers_stacked_chart_week(transfers, negative: true)
        end

        it 'should return correct chart data' do
          expect(transfers_stacked_chart_week).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => -7, 'burn' => 0,
              :i => Time.zone.local(2021, 3, 29).to_i, :timeframe => "29\tMar"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 5).to_i, :timeframe => "05\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => -3,
              :i => Time.zone.local(2021, 4, 12).to_i, :timeframe => "12\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 19).to_i, :timeframe => "19\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 26).to_i, :timeframe => "26\tApr"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 3).to_i, :timeframe => "03\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 10).to_i, :timeframe => "10\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 17).to_i, :timeframe => "17\tMay"
            },
            {
              'bought' => 0, 'earned' => -10, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 24).to_i, :timeframe => "24\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => -5, 'burn' => -13,
              :i => Time.zone.local(2021, 5, 31).to_i, :timeframe => "31\tMay"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 7).to_i, :timeframe => "07\tJun"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 14).to_i, :timeframe => "14\tJun"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 21).to_i, :timeframe => "21\tJun"
            }
          ]
        end
      end
    end
  end

  describe '#transfers_stacked_chart_month' do
    let(:now) { Time.zone.local(2021, 6, 21) }
    let(:project) { FactoryBot.create(:project) }
    let(:earned_transfer_type) { TransferType.find_by(name: 'earned') }
    let(:bought_transfer_type) { TransferType.find_by(name: 'bought') }
    let!(:mint_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'mint') }
    let!(:burn_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'burn') }

    before { Timecop.freeze(now) }

    after { Timecop.return }

    context 'when no awards' do
      let(:transfers) { Award.none }

      shared_examples 'return data for chart with zeros' do
        it do
          expect(transfers_stacked_chart_month).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 6, 1).to_i, :timeframe => "Jun\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 7, 1).to_i, :timeframe => "Jul\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 8, 1).to_i, :timeframe => "Aug\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 9, 1).to_i, :timeframe => "Sep\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 10, 1).to_i, :timeframe => "Oct\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 11, 1).to_i, :timeframe => "Nov\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 12, 1).to_i, :timeframe => "Dec\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 1, 1).to_i, :timeframe => "Jan\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 2, 1).to_i, :timeframe => "Feb\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 3, 1).to_i, :timeframe => "Mar\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 1).to_i, :timeframe => "Apr\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 1).to_i, :timeframe => "May\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 1).to_i, :timeframe => "Jun\t'21"
            }
          ]
        end
      end

      context 'when regular' do
        subject(:transfers_stacked_chart_month) do
          project.decorate.transfers_stacked_chart_month(transfers)
        end

        it_behaves_like 'return data for chart with zeros'
      end

      context 'when negative' do
        subject(:transfers_stacked_chart_month) do
          project.decorate.transfers_stacked_chart_month(transfers, negative: true)
        end

        it_behaves_like 'return data for chart with zeros'
      end
    end

    context 'when with awards' do
      let(:award_type) { FactoryBot.create(:award_type, project: project) }
      let!(:award1) do
        FactoryBot.create :award, project: project, transfer_type: earned_transfer_type,
                                  created_at: Time.zone.local(2021, 3, 24), amount: 5, quantity: 2,
                                  award_type: award_type
      end
      let!(:award2) do
        FactoryBot.create :award, project: project, transfer_type: burn_transfer_type,
                                  created_at: Time.zone.local(2021, 2, 2), amount: 13,
                                  award_type: award_type
      end
      let!(:award3) do
        FactoryBot.create :award, project: project, transfer_type: burn_transfer_type,
                                  created_at: Time.zone.local(2021, 1, 15), amount: 3,
                                  award_type: award_type
      end
      let!(:award4) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2020, 7, 2), amount: 7,
                                  award_type: award_type
      end
      let!(:award5) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2021, 5, 31), amount: 5
      end
      let!(:award6) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2020, 5, 31), amount: 45
      end

      let(:other_project) { FactoryBot.create :project }
      let!(:other_transfer_type) do
        FactoryBot.create(:transfer_type, project: other_project, name: 'mint')
      end
      let!(:other_award1) do
        FactoryBot.create :award, project: other_project, transfer_type: other_transfer_type,
                                  created_at: Time.zone.local(2021, 2, 15), amount: 7
      end

      let(:transfers) { project.awards }

      context 'when regular' do
        subject(:transfers_stacked_chart_month) do
          project.decorate.transfers_stacked_chart_month(transfers)
        end

        it 'should return correct chart data' do
          expect(transfers_stacked_chart_month).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 6, 1).to_i, :timeframe => "Jun\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 7, 'burn' => 0,
              :i => Time.zone.local(2020, 7, 1).to_i, :timeframe => "Jul\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 8, 1).to_i, :timeframe => "Aug\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 9, 1).to_i, :timeframe => "Sep\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 10, 1).to_i, :timeframe => "Oct\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 11, 1).to_i, :timeframe => "Nov\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 12, 1).to_i, :timeframe => "Dec\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 3,
              :i => Time.zone.local(2021, 1, 1).to_i, :timeframe => "Jan\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 13,
              :i => Time.zone.local(2021, 2, 1).to_i, :timeframe => "Feb\t'21"
            },
            {
              'bought' => 0, 'earned' => 10, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 3, 1).to_i, :timeframe => "Mar\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 1).to_i, :timeframe => "Apr\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 5, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 1).to_i, :timeframe => "May\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 1).to_i, :timeframe => "Jun\t'21"
            }
          ]
        end
      end

      context 'when negative' do
        subject(:transfers_stacked_chart_month) do
          project.decorate.transfers_stacked_chart_month(transfers, negative: true)
        end

        it 'should return correct chart data' do
          expect(transfers_stacked_chart_month).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 6, 1).to_i, :timeframe => "Jun\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => -7, 'burn' => 0,
              :i => Time.zone.local(2020, 7, 1).to_i, :timeframe => "Jul\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 8, 1).to_i, :timeframe => "Aug\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 9, 1).to_i, :timeframe => "Sep\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 10, 1).to_i, :timeframe => "Oct\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 11, 1).to_i, :timeframe => "Nov\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 12, 1).to_i, :timeframe => "Dec\t'20"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => -3,
              :i => Time.zone.local(2021, 1, 1).to_i, :timeframe => "Jan\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => -13,
              :i => Time.zone.local(2021, 2, 1).to_i, :timeframe => "Feb\t'21"
            },
            {
              'bought' => 0, 'earned' => -10, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 3, 1).to_i, :timeframe => "Mar\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 4, 1).to_i, :timeframe => "Apr\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => -5, 'burn' => 0,
              :i => Time.zone.local(2021, 5, 1).to_i, :timeframe => "May\t'21"
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 6, 1).to_i, :timeframe => "Jun\t'21"
            }
          ]
        end
      end
    end
  end

  describe '#transfers_stacked_chart_year' do
    subject(:transfers_stacked_chart_year) do
      project.decorate.transfers_stacked_chart_year(transfers)
    end

    let(:now) { Time.zone.local(2021, 6, 21) }
    let(:project) { FactoryBot.create(:project) }
    let(:earned_transfer_type) { TransferType.find_by(name: 'earned') }
    let(:bought_transfer_type) { TransferType.find_by(name: 'bought') }
    let!(:mint_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'mint') }
    let!(:burn_transfer_type) { FactoryBot.create(:transfer_type, project: project, name: 'burn') }

    before { Timecop.freeze(now) }

    after { Timecop.return }

    context 'when no awards' do
      let(:transfers) { Award.none }

      shared_examples 'return chart data with zeros' do
        it do
          expect(transfers_stacked_chart_year).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2011, 1, 1).to_i, :timeframe => '2011'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2012, 1, 1).to_i, :timeframe => '2012'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2013, 1, 1).to_i, :timeframe => '2013'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2014, 1, 1).to_i, :timeframe => '2014'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2015, 1, 1).to_i, :timeframe => '2015'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2016, 1, 1).to_i, :timeframe => '2016'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2017, 1, 1).to_i, :timeframe => '2017'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2018, 1, 1).to_i, :timeframe => '2018'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2019, 1, 1).to_i, :timeframe => '2019'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2020, 1, 1).to_i, :timeframe => '2020'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 1, 1).to_i, :timeframe => '2021'
            }
          ]
        end
      end

      context 'when regular' do
        subject(:transfers_stacked_chart_year) do
          project.decorate.transfers_stacked_chart_year(transfers)
        end

        it_behaves_like 'return chart data with zeros'
      end

      context 'when negative' do
        subject(:transfers_stacked_chart_year) do
          project.decorate.transfers_stacked_chart_year(transfers, negative: true)
        end

        it_behaves_like 'return chart data with zeros'
      end
    end

    context 'when with awards' do
      let(:award_type) { FactoryBot.create(:award_type, project: project) }
      let!(:award1) do
        FactoryBot.create :award, project: project, transfer_type: earned_transfer_type,
                                  created_at: Time.zone.local(2015, 3, 24), amount: 5, quantity: 2,
                                  award_type: award_type
      end
      let!(:award2) do
        FactoryBot.create :award, project: project, transfer_type: burn_transfer_type,
                                  created_at: Time.zone.local(2017, 10, 2), amount: 13,
                                  award_type: award_type
      end
      let!(:award3) do
        FactoryBot.create :award, project: project, transfer_type: burn_transfer_type,
                                  created_at: Time.zone.local(2017, 10, 15), amount: 3,
                                  award_type: award_type
      end
      let!(:award4) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2019, 2, 2), amount: 7,
                                  award_type: award_type
      end
      let!(:award5) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2020, 5, 31), amount: 5
      end
      let!(:award6) do
        FactoryBot.create :award, project: project, transfer_type: mint_transfer_type,
                                  created_at: Time.zone.local(2005, 4, 1), amount: 70
      end

      let(:other_project) { FactoryBot.create :project }
      let!(:other_transfer_type) do
        FactoryBot.create(:transfer_type, project: other_project, name: 'mint')
      end
      let!(:other_award1) do
        FactoryBot.create :award, project: other_project, transfer_type: other_transfer_type,
                                  created_at: Time.zone.local(2018, 2, 15), amount: 7
      end

      let(:transfers) { project.awards }

      context 'when regular' do
        subject(:transfers_stacked_chart_year) do
          project.decorate.transfers_stacked_chart_year(transfers)
        end

        it 'should return correct chart data' do
          expect(transfers_stacked_chart_year).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2011, 1, 1).to_i, :timeframe => '2011'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2012, 1, 1).to_i, :timeframe => '2012'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2013, 1, 1).to_i, :timeframe => '2013'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2014, 1, 1).to_i, :timeframe => '2014'
            },
            {
              'bought' => 0, 'earned' => 10, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2015, 1, 1).to_i, :timeframe => '2015'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2016, 1, 1).to_i, :timeframe => '2016'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 16,
              :i => Time.zone.local(2017, 1, 1).to_i, :timeframe => '2017'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2018, 1, 1).to_i, :timeframe => '2018'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 7, 'burn' => 0,
              :i => Time.zone.local(2019, 1, 1).to_i, :timeframe => '2019'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 5, 'burn' => 0,
              :i => Time.zone.local(2020, 1, 1).to_i, :timeframe => '2020'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 1, 1).to_i, :timeframe => '2021'
            }
          ]
        end
      end

      context 'when negative' do
        subject(:transfers_stacked_chart_year) do
          project.decorate.transfers_stacked_chart_year(transfers, negative: true)
        end

        it 'should return correct chart data' do
          expect(transfers_stacked_chart_year).to eq [
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2011, 1, 1).to_i, :timeframe => '2011'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2012, 1, 1).to_i, :timeframe => '2012'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2013, 1, 1).to_i, :timeframe => '2013'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2014, 1, 1).to_i, :timeframe => '2014'
            },
            {
              'bought' => 0, 'earned' => -10, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2015, 1, 1).to_i, :timeframe => '2015'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2016, 1, 1).to_i, :timeframe => '2016'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => -16,
              :i => Time.zone.local(2017, 1, 1).to_i, :timeframe => '2017'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2018, 1, 1).to_i, :timeframe => '2018'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => -7, 'burn' => 0,
              :i => Time.zone.local(2019, 1, 1).to_i, :timeframe => '2019'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => -5, 'burn' => 0,
              :i => Time.zone.local(2020, 1, 1).to_i, :timeframe => '2020'
            },
            {
              'bought' => 0, 'earned' => 0, 'mint' => 0, 'burn' => 0,
              :i => Time.zone.local(2021, 1, 1).to_i, :timeframe => '2021'
            }
          ]
        end
      end
    end
  end
end
