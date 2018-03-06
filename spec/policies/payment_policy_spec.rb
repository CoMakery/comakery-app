require 'rails_helper'

describe PaymentPolicy do
  let!(:project_account_no_awards) do
    create(:account).tap do |a|
      create(:authentication, account: a, slack_team_id: 'citizen code id', updated_at: 1.day.ago)
      create(:authentication, account: a, slack_team_id: 'other slack team id', updated_at: 2.days.ago)
    end
  end
  let!(:my_public_project) { create(:project, title: 'public mine', account: project_account_no_awards, public: true, slack_team_id: 'citizen code id') }
  let!(:award_type) { create :award_type, amount: 1000, project: my_public_project }

  let!(:contributor_with_award) do
    create(:account).tap do |a|
      award_type.awards.create_with_quantity 1,
        authentication: create(:authentication, account: a, slack_team_id: 'citizen code id'),
        issuer: project_account_no_awards
    end
  end

  let!(:payment_my_project) { build :project_payment, project: my_public_project }
  let!(:payment_not_my_project) { build :project_payment }

  let!(:member_on_my_team_no_awards) { create(:account).tap { |a| create(:authentication, account: a, slack_team_id: 'citizen code id') } }
  let(:payment_with_no_proejct) { Payment.new }

  permissions :create? do
    specify { allow contributor_with_award, payment_my_project }

    specify { deny member_on_my_team_no_awards, payment_my_project }
    specify { deny nil, payment_my_project }

    specify { deny member_on_my_team_no_awards, payment_not_my_project }
  end

  permissions :update? do
    specify { allow project_account_no_awards, payment_my_project }

    specify { deny project_account_no_awards, payment_with_no_proejct }

    specify { deny contributor_with_award, payment_my_project }

    specify { deny nil, payment_my_project }
  end

  def allow(*args)
    expect(PaymentPolicy).to permit(*args)
  end

  def deny(*args)
    expect(PaymentPolicy).not_to permit(*args)
  end
end
