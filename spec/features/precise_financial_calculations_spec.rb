# frozen_string_literal: true

require 'rails_helper'

describe 'precise financial calculations across the integrated revenue sharing cycle' do
  let!(:team) { create :team }
  let!(:owner) { create(:account) }

  let!(:owner_auth) do
    create(:authentication,
      account: owner)
  end

  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1' * 40}") }

  let!(:same_team_account_auth) do
    create(:authentication,
      account: same_team_account)
  end

  before do
    team.build_authentication_team owner_auth
    team.build_authentication_team same_team_account_auth
    stub_slack_user_list
    stub_slack_channel_list
  end

  shared_examples_for 'check sums' do
    specify { expect(project.total_awards_outstanding + project.payments.total_awards_redeemed).to eq(project.total_awarded) }
    specify { expect(project.total_revenue * (project.royalty_percentage * 0.01)).to eq(project.total_revenue_shared) }
    specify { expect(project.total_revenue_shared_unpaid + project.payments.total_value_redeemed).to eq(project.total_revenue_shared) }
    specify { expect(project.share_of_revenue_unpaid(project.total_awards_outstanding)).to eq(project.total_revenue_shared_unpaid) }
    specify { expect(project.share_of_revenue_unpaid(1)).to eq(project.revenue_per_share) }

    specify do
      expect(owner.total_awards_earned(project) +
                 same_team_account.total_awards_earned(project)).to eq(project.total_awarded)
    end

    specify do
      expect(owner.total_awards_paid(project) +
                 same_team_account.total_awards_paid(project)).to eq(project.payments.total_awards_redeemed)
    end

    specify do
      expect(owner.total_awards_remaining(project) +
                 same_team_account.total_awards_remaining(project)).to eq(project.total_awards_outstanding)
    end

    specify do
      expect(owner.total_revenue_paid(project) +
                 same_team_account.total_revenue_paid(project)).to eq(project.payments.total_value_redeemed)
    end

    specify do
      expect(owner.total_revenue_unpaid(project) +
                 same_team_account.total_revenue_unpaid(project)).to eq(project.total_revenue_shared_unpaid)
    end
  end

  describe 'empty' do
    let!(:project) do
      create(:project,
        royalty_percentage: BigDecimal('99.999999'),
        visibility: 'public_listed',
        payment_type: 'revenue_share',
        account: owner,
        require_confidentiality: false)
    end

    it_behaves_like 'check sums'
  end

  describe 'with revenues, awards, and payments and simple numbers' do
    let!(:project) do
      create(:project,
        royalty_percentage: BigDecimal('100'),
        visibility: 'public_listed',
        account: owner,
        payment_type: 'revenue_share',
        require_confidentiality: false)
    end

    let!(:code_award_type) do
      project.award_types.create(community_awardable: false,
                                 amount: 1,
                                 name: 'Code Contribution')
    end
    let!(:same_team_award) do
      create(:award, award_type: code_award_type, quantity: 50,
                     issuer: owner,
                     account: same_team_account)
    end

    let!(:owner_award) do
      create(:award, award_type: code_award_type, quantity: 50,
                     issuer: owner,
                     account: owner)
    end

    let!(:revenues) do
      project.revenues.create(amount: 100,
                              currency: 'USD',
                              recorded_by: owner)
    end

    let!(:payments) do
      project.payments.create_with_quantity(quantity_redeemed: 25,
                                            account: owner)
    end

    it_behaves_like 'check sums'
  end

  describe 'with revenues, awards, and payments and decimal royalties' do
    let!(:project) do
      create(:project,
        royalty_percentage: BigDecimal('99.99'),
        visibility: 'public_listed',
        account: owner,
        payment_type: 'revenue_share',
        require_confidentiality: false)
    end

    let!(:code_award_type) do
      project.award_types.create(community_awardable: false,
                                 amount: 1,
                                 name: 'Code Contribution')
    end
    let!(:same_team_award) do
      create(:award, award_type: code_award_type, quantity: 50,
                     issuer: owner,
                     account: same_team_account)
    end

    let!(:owner_award) do
      create(:award, award_type: code_award_type, quantity: 50,
                     issuer: owner,
                     account: owner)
    end

    let!(:revenues) do
      project.revenues.create(amount: 100,
                              currency: 'USD',
                              recorded_by: owner)
    end

    let!(:payments) do
      project.payments.create_with_quantity(quantity_redeemed: 25,
                                            account: owner)
    end

    it_behaves_like 'check sums'
  end

  shared_examples_for 'precise revenue share value' do |quantity_redeemed:, expected_price_per_share:, expected_share_of_revenue_unpaid_single_share_value: 1|
    describe "when redeeming #{quantity_redeemed} revenue shares" do
      before do
        project.payments.create_with_quantity(quantity_redeemed: quantity_redeemed, account: owner)
      end

      specify { expect(project.revenue_per_share).to eq(expected_price_per_share) }
      specify { expect(project.share_of_revenue_unpaid(1)).to eq(expected_share_of_revenue_unpaid_single_share_value) }
    end
  end

  describe 'with 100% royalties' do
    let!(:project) do
      create(:project,
        royalty_percentage: BigDecimal('100'),
        visibility: 'public_listed',
        account: owner,
        payment_type: 'revenue_share',
        require_confidentiality: false)
    end

    let!(:code_award_type) do
      project.award_types.create(community_awardable: false,
                                 amount: 1,
                                 name: 'Code Contribution')
    end
    let!(:same_team_award) do
      create(:award, award_type: code_award_type, quantity: 50_000_000,
                     issuer: owner,
                     account: same_team_account)
    end

    let!(:owner_award) do
      create(:award, award_type: code_award_type, quantity: 50_000_000,
                     issuer: owner,
                     account: owner)
    end

    let!(:revenues) do
      project.revenues.create(amount: 100_000_000,
                              currency: 'USD',
                              recorded_by: owner)
    end

    it_behaves_like 'precise revenue share value', quantity_redeemed: 0, expected_price_per_share: 1
    it_behaves_like 'precise revenue share value', quantity_redeemed: 7, expected_price_per_share: 1
    it_behaves_like 'precise revenue share value', quantity_redeemed: 13, expected_price_per_share: 1
    it_behaves_like 'precise revenue share value', quantity_redeemed: 25, expected_price_per_share: 1
    it_behaves_like 'precise revenue share value', quantity_redeemed: (13 * 17 * 23), expected_price_per_share: 1
  end

  describe 'with 99 and 20 nines royalty percentage' do
    let(:royalty_percentage_with_20_nines) { BigDecimal('99.' + ('9' * 20)) }

    let!(:project) do
      create(:project,
        royalty_percentage: royalty_percentage_with_20_nines,
        visibility: 'public_listed',
        payment_type: 'revenue_share',
        account: owner,
        require_confidentiality: false)
    end

    let!(:code_award_type) do
      project.award_types.create(community_awardable: false,
                                 amount: 1,
                                 name: 'Code Contribution')
    end
    let!(:same_team_award) do
      create(:award, award_type: code_award_type, quantity: 50_000_000,
                     issuer: owner,
                     account: same_team_account)
    end

    let!(:owner_award) do
      create(:award, award_type: code_award_type, quantity: 50_000_000,
                     issuer: owner,
                     account: owner)
    end

    let!(:revenues) do
      project.revenues.create(amount: 100_000_000,
                              currency: 'USD',
                              recorded_by: owner)
    end

    it_behaves_like 'precise revenue share value',
      quantity_redeemed: 0,
      expected_price_per_share: BigDecimal('0.' + ('9' * 8)),
      expected_share_of_revenue_unpaid_single_share_value: BigDecimal('0.' + ('9' * 2))

    it_behaves_like 'precise revenue share value',
      quantity_redeemed: 7,
      expected_price_per_share: 1

    it_behaves_like 'precise revenue share value',
      quantity_redeemed: 13,
      expected_price_per_share: 1

    it_behaves_like 'precise revenue share value',
      quantity_redeemed: 25,
      expected_price_per_share: 1

    it_behaves_like 'precise revenue share value',
      quantity_redeemed: (13 * 17 * 23),
      expected_price_per_share: 1

    it_behaves_like 'precise revenue share value',
      quantity_redeemed: 99_999_999,
      expected_price_per_share: BigDecimal('0.' + ('9' * 8)),
      expected_share_of_revenue_unpaid_single_share_value: 0.99
  end

  it 'simple awards, revenue, and payments in USD' do
    # 1) create project
    project = create(:project,
      royalty_percentage: 100,
      visibility: 'public_listed',
      payment_type: 'revenue_share',
      account: owner,
      require_confidentiality: false)

    # project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(0)
    expect(project.total_awards_outstanding).to eq(0)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner.total_awards_earned(project)).to eq(0)
    expect(owner.total_awards_paid(project)).to eq(0)
    expect(owner.total_awards_remaining(project)).to eq(0)

    expect(owner.total_revenue_paid(project)).to eq(0)
    expect(owner.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 2) issue awards
    # ---
    code_award_type = project.award_types.create(community_awardable: false, name: 'Code Contribution')
    create(:award, award_type: code_award_type, quantity: 50, amount: 1, issuer: owner, account: same_team_account)
    create(:award, award_type: code_award_type, quantity: 50, amount: 1, issuer: owner, account: owner)

    # project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner.total_awards_earned(project)).to eq(50)
    expect(owner.total_awards_paid(project)).to eq(0)
    expect(owner.total_awards_remaining(project)).to eq(50)

    expect(owner.total_revenue_paid(project)).to eq(0)
    expect(owner.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 3) record revenue
    # ---

    project.revenues.create(amount: 100, currency: 'USD', recorded_by: owner)

    # project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(1)
    expect(project.total_revenue_shared).to eq(100)
    expect(project.total_revenue_shared_unpaid).to eq(100)
    expect(project.revenue_per_share).to eq(1)

    # auth
    expect(owner.total_awards_earned(project)).to eq(50)
    expect(owner.total_awards_paid(project)).to eq(0)
    expect(owner.total_awards_remaining(project)).to eq(50)

    expect(owner.total_revenue_paid(project)).to eq(0)
    expect(owner.total_revenue_unpaid(project)).to eq(50)

    # ---
    # 4) pay contributors
    # ---

    project.payments.create_with_quantity(quantity_redeemed: 25, account: owner)

    # project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_revenue_shared).to eq(100)
    expect(project.total_awards_outstanding).to eq(75)
    expect(project.total_revenue_shared_unpaid).to eq(75)
    expect(project.revenue_per_share).to eq(1)
    expect(project.share_of_revenue_unpaid(1)).to eq(1)

    # auth
    expect(owner.total_awards_earned(project)).to eq(50)
    expect(owner.total_awards_paid(project)).to eq(25)
    expect(owner.total_awards_remaining(project)).to eq(25)

    expect(owner.total_revenue_paid(project)).to eq(25)
    expect(owner.total_revenue_unpaid(project)).to eq(25)

    expect(same_team_account.total_awards_earned(project)).to eq(50)
    expect(same_team_account.total_awards_paid(project)).to eq(0)
    expect(same_team_account.total_awards_remaining(project)).to eq(50)

    expect(same_team_account.total_revenue_paid(project)).to eq(0)
    expect(same_team_account.total_revenue_unpaid(project)).to eq(50)
  end

  it 'high precision awards, revenue, and payments in USD' do
    almost_100 = BigDecimal('99.' + ('9' * 19)) # this highlights precision and potential rounding errors
    ninety_nine_point_13_nines = almost_100.truncate(13)
    zero_point_15_nines = BigDecimal('0.' + ('9' * 15))
    seventy_four_point_13_nines_and_25 = BigDecimal('74.' + ('9' * 13) + '25')
    forty_nine_point_13_nines_and_a_five = BigDecimal('0.' + ('9' * 15)) * BigDecimal(50)

    # 1) create project
    project = create(:project,
      royalty_percentage: almost_100,
      visibility: 'public_listed',
      account: owner,
      payment_type: 'revenue_share',
      require_confidentiality: false)

    expect(project.reload.royalty_percentage).to eq(ninety_nine_point_13_nines)

    # project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(0)
    expect(project.total_awards_outstanding).to eq(0)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner.total_awards_earned(project)).to eq(0)
    expect(owner.total_awards_paid(project)).to eq(0)
    expect(owner.total_awards_remaining(project)).to eq(0)

    expect(owner.total_revenue_paid(project)).to eq(0)
    expect(owner.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 2) issue awards
    # ---
    code_award_type = project.award_types.create(community_awardable: false, name: 'Code Contribution')
    create(:award, award_type: code_award_type, quantity: 50, amount: 1, issuer: owner, account: same_team_account)
    create(:award, award_type: code_award_type, quantity: 50, amount: 1, issuer: owner, account: owner)

    # project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner.total_awards_earned(project)).to eq(50)
    expect(owner.total_awards_paid(project)).to eq(0)
    expect(owner.total_awards_remaining(project)).to eq(50)

    expect(owner.total_revenue_paid(project)).to eq(0)
    expect(owner.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 3) record revenue
    # ---

    project.revenues.create(amount: 100, currency: 'USD', recorded_by: owner)

    # project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(BigDecimal('0.99'))
    expect(project.total_revenue_shared).to eq(ninety_nine_point_13_nines)
    expect(project.total_revenue_shared_unpaid).to eq(ninety_nine_point_13_nines)
    expect(project.revenue_per_share).to eq(BigDecimal('0.' + ('9' * 8)))

    # auth
    expect(owner.total_awards_earned(project)).to eq(50)
    expect(owner.total_awards_paid(project)).to eq(0)
    expect(owner.total_awards_remaining(project)).to eq(50)

    expect(owner.total_revenue_paid(project)).to eq(0)
    expect(owner.total_revenue_unpaid(project)).to eq(BigDecimal('49.99'))

    # ---
    # 4) pay contributors
    # ---

    payment = project.payments.create_with_quantity(quantity_redeemed: 25, account: owner)
    expect(payment.total_value).to eq(24.99) # rounded to USD precision

    # project

    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_revenue_shared).to eq(ninety_nine_point_13_nines)
    expect(project.total_awards_outstanding).to eq(75)

    revenue_shared_minus_truncated_payment = ninety_nine_point_13_nines - 24.99
    expect(project.total_revenue_shared_unpaid).to eq(revenue_shared_minus_truncated_payment)

    new_price_per_share_after_reclaiming_truncated_values_like_richard_prior_in_superman3 =
      (revenue_shared_minus_truncated_payment / BigDecimal('75')).truncate(8)

    expect(project.revenue_per_share).to eq(new_price_per_share_after_reclaiming_truncated_values_like_richard_prior_in_superman3)

    expect(project.share_of_revenue_unpaid(1))
      .to eq(new_price_per_share_after_reclaiming_truncated_values_like_richard_prior_in_superman3.truncate(2))

    # auth
    expect(owner.total_awards_earned(project)).to eq(50)
    expect(owner.total_awards_paid(project)).to eq(25)
    expect(owner.total_awards_remaining(project)).to eq(25)

    expect(owner.total_revenue_paid(project)).to eq(24.99)
    expect(owner.total_revenue_unpaid(project)).to eq(
      ((revenue_shared_minus_truncated_payment * BigDecimal('25')) /
          BigDecimal('75')).truncate(2)
    )

    expect(same_team_account.total_awards_earned(project)).to eq(50)
    expect(same_team_account.total_awards_paid(project)).to eq(0)
    expect(same_team_account.total_awards_remaining(project)).to eq(50)

    expect(same_team_account.total_revenue_paid(project)).to eq(0)
    expect(same_team_account.total_revenue_unpaid(project))
      .to eq(((revenue_shared_minus_truncated_payment * BigDecimal('50')) / BigDecimal('75')).truncate(2))
  end
end
