require 'rails_helper'

describe PaymentPolicy do
  let!(:team1) {create :team}
  let!(:team2) {create :team}
  let!(:account) {create :account}
  let!(:authentication1) { create(:authentication, account: account) }
  let!(:authentication2) { create(:authentication, account: account) }
  let!(:receiver) {create :account}
  let!(:receiver_auth) {create :authentication, account: receiver}
  let!(:my_public_project) { create(:project, title: 'public mine', account: account, public: true) }
  let!(:award_type) { create :award_type, amount: 1000, project: my_public_project }

  let!(:payment_my_project) { build :project_payment, project: my_public_project }
  let!(:payment_not_my_project) { build :project_payment }

  let!(:member_on_my_team_no_awards) { create(:account)}
  let!(:member_on_my_team_no_awards_auth) {create :authentication, account: member_on_my_team_no_awards}
  let(:payment_with_no_project) { Payment.new }

  before do
    team1.build_authentication_team authentication1
    team2.build_authentication_team authentication2
    award_type.awards.create_with_quantity 1, issuer: account, account: receiver
  end

  permissions :create? do
    specify { allow receiver, payment_my_project }

    specify { deny member_on_my_team_no_awards, payment_my_project }
    specify { deny nil, payment_my_project }

    specify { deny member_on_my_team_no_awards, payment_not_my_project }
  end

  permissions :update? do
    specify { allow account, payment_my_project }

    specify { deny account, payment_with_no_project }

    specify { deny receiver, payment_my_project }

    specify { deny nil, payment_my_project }
  end

  def allow(*args)
    expect(PaymentPolicy).to permit(*args)
  end

  def deny(*args)
    expect(PaymentPolicy).not_to permit(*args)
  end
end
