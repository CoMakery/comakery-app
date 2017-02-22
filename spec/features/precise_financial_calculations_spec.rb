require "rails_helper"

describe "precise financial calculations across the integrated revenue sharing cycle" do
  let!(:owner) { create(:account) }

  let!(:owner_auth) { create(:authentication,
                             account: owner,
                             slack_team_id: "foo",
                             slack_image_32_url: "http://avatar.com/owner.jpg") }

  let!(:same_team_account) { create(:account, ethereum_wallet: "0x#{'1'*40}") }

  let!(:same_team_account_auth) { create(:authentication,
                                         account: same_team_account,
                                         slack_team_id: "lazercats",
                                         slack_team_name: "Lazer Cats") }
  before do
    stub_slack_user_list
    stub_slack_channel_list
  end

  it 'simple awards, revenue, and payments in USD' do
    # 1) create project
    project = create(:project,
                     royalty_percentage: 100,
                     public: true,
                     owner_account: owner,
                     slack_team_id: "foo",
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
    expect(owner_auth.total_awards_earned(project)).to eq(0)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(0)

    expect(owner_auth.total_revenue_earned(project)).to eq(0)
    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)


    # ---
    # 2) issue awards
    # ---
    code_award_type = project.award_types.create(community_awardable: false, amount: 1, name: 'Code Contribution')
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: same_team_account_auth)
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: owner_auth)

    #project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)

    expect(owner_auth.total_revenue_earned(project)).to eq(0)
    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 3) record revenue
    # ---

    project.revenues.create(amount: 100, currency: 'USD', recorded_by: owner)

    #project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(1)
    expect(project.total_revenue_shared).to eq(100)
    expect(project.total_revenue_shared_unpaid).to eq(100)
    expect(project.revenue_per_share).to eq(1)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)

    expect(owner_auth.total_revenue_earned(project)).to eq(50)
    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(50)

    # ---
    # 4) pay contributors
    # ---

    project.payments.create_with_quantity(quantity_redeemed: 25, payee_auth: owner_auth)

    #project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_revenue_shared).to eq(100)
    expect(project.total_awards_outstanding).to eq(75)
    expect(project.total_revenue_shared_unpaid).to eq(75)
    expect(project.revenue_per_share).to eq(1)
    expect(project.share_of_revenue_unpaid(1)).to eq(1)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(25)
    expect(owner_auth.total_awards_remaining(project)).to eq(25)

    expect(owner_auth.total_revenue_earned(project)).to eq(50)
    expect(owner_auth.total_revenue_paid(project)).to eq(25)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(25)

    expect(same_team_account_auth.total_awards_earned(project)).to eq(50)
    expect(same_team_account_auth.total_awards_paid(project)).to eq(0)
    expect(same_team_account_auth.total_awards_remaining(project)).to eq(50)

    expect(same_team_account_auth.total_revenue_earned(project)).to eq(50)
    expect(same_team_account_auth.total_revenue_paid(project)).to eq(0)
    expect(same_team_account_auth.total_revenue_unpaid(project)).to eq(50)
  end

  it 'high precision awards, revenue, and payments in USD' do
    almost_100 = BigDecimal('99.' + ('9'*19))
    ninety_nine_point_13_nines = almost_100.truncate(13)
    zero_point_15_nines = BigDecimal('0.' + ('9' * 15))
    seventy_four_point_13_nines_and_25 = BigDecimal('74.' + ('9' * 13) + '25')
    forty_nine_point_13_nines_and_a_five = BigDecimal('0.' + ('9' * 15)) * BigDecimal(50)

    # 1) create project
    project = create(:project,
                     royalty_percentage: almost_100,
                     public: true,
                     owner_account: owner,
                     slack_team_id: "foo",
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
    expect(owner_auth.total_awards_earned(project)).to eq(0)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(0)

    expect(owner_auth.total_revenue_earned(project)).to eq(0)
    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)


    # ---
    # 2) issue awards
    # ---
    code_award_type = project.award_types.create(community_awardable: false, amount: 1, name: 'Code Contribution')
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: same_team_account_auth)
    code_award_type.awards.create_with_quantity(50, issuer: owner, authentication: owner_auth)

    #project
    expect(project.total_revenue).to eq(0)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(0)
    expect(project.total_revenue_shared).to eq(0)
    expect(project.total_revenue_shared_unpaid).to eq(0)
    expect(project.revenue_per_share).to eq(0)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)

    expect(owner_auth.total_revenue_earned(project)).to eq(0)
    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(0)

    # ---
    # 3) record revenue
    # ---

    project.revenues.create(amount: 100, currency: 'USD', recorded_by: owner)

    #project
    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_awards_outstanding).to eq(100)
    expect(project.share_of_revenue_unpaid(1)).to eq(BigDecimal('0.' + ('9' * 15)))
    expect(project.total_revenue_shared).to eq(ninety_nine_point_13_nines)
    expect(project.total_revenue_shared_unpaid).to eq(ninety_nine_point_13_nines)
    expect(project.revenue_per_share).to eq(BigDecimal('0.' + ('9' * 15)))

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(0)
    expect(owner_auth.total_awards_remaining(project)).to eq(50)


    expect(owner_auth.total_revenue_earned(project)).to eq(forty_nine_point_13_nines_and_a_five)
    expect(owner_auth.total_revenue_paid(project)).to eq(0)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(forty_nine_point_13_nines_and_a_five)

    # ---
    # 4) pay contributors
    # ---

    project.payments.create_with_quantity(quantity_redeemed: 25, payee_auth: owner_auth)

    #project

    expect(project.total_revenue).to eq(100)
    expect(project.total_awarded).to eq(100)
    expect(project.total_revenue_shared).to eq(ninety_nine_point_13_nines)
    expect(project.total_awards_outstanding).to eq(75)
    expect(project.total_revenue_shared_unpaid).to eq(seventy_four_point_13_nines_and_25)
    expect(project.revenue_per_share).to eq(zero_point_15_nines)
    expect(project.share_of_revenue_unpaid(1)).to eq(zero_point_15_nines)

    # auth
    expect(owner_auth.total_awards_earned(project)).to eq(50)
    expect(owner_auth.total_awards_paid(project)).to eq(25)
    expect(owner_auth.total_awards_remaining(project)).to eq(25)

    expect(owner_auth.total_revenue_earned(project)).to eq(forty_nine_point_13_nines_and_a_five)
    expect(owner_auth.total_revenue_paid(project)).to eq(BigDecimal(25) * zero_point_15_nines)
    expect(owner_auth.total_revenue_unpaid(project)).to eq(BigDecimal(25) * zero_point_15_nines)

    expect(same_team_account_auth.total_awards_earned(project)).to eq(50)
    expect(same_team_account_auth.total_awards_paid(project)).to eq(0)
    expect(same_team_account_auth.total_awards_remaining(project)).to eq(50)

    expect(same_team_account_auth.total_revenue_earned(project)).to eq(forty_nine_point_13_nines_and_a_five)
    expect(same_team_account_auth.total_revenue_paid(project)).to eq(0)
    expect(same_team_account_auth.total_revenue_unpaid(project)).to eq(forty_nine_point_13_nines_and_a_five)
  end
end