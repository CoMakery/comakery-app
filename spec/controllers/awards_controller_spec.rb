require 'rails_helper'

describe AwardsController do
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:issuer) { create(:authentication) }
  let!(:issuer_discord) { create(:authentication, account: issuer.account, provider: 'discord') }
  let!(:receiver) { create(:authentication) }
  let!(:receiver_discord) { create(:authentication, account: receiver.account, provider: 'discord') }
  let!(:other_auth) { create(:authentication) }
  let!(:different_team_account) { create(:authentication) }

  let(:project) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000) }

  before do
    stub_discord_channels
    team.build_authentication_team issuer
    team.build_authentication_team receiver
    team.build_authentication_team other_auth
    discord_team.build_authentication_team issuer_discord
    discord_team.build_authentication_team receiver_discord
    project.channels.create(team: team, channel_id: '123')
  end
  describe '#index' do
    let!(:award) { create(:award, award_type: create(:award_type, project: project), account: other_auth.account) }
    let!(:different_project_award) { create(:award, award_type: create(:award_type, project: create(:project)), account: other_auth.account) }

    context 'when logged in' do
      before { login(issuer.account) }

      it 'shows awards for current project' do
        get :index, params: { project_id: project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(project)
        expect(assigns[:awards]).to match_array([award])
      end
    end

    context 'when logged out' do
      context 'with a public project' do
        let!(:public_project) { create(:project, account: issuer.account, visibility: 'public_listed') }
        let!(:public_award) { create(:award, award_type: create(:award_type, project: public_project)) }

        it 'shows awards for public projects' do
          get :index, params: { project_id: public_project.to_param }

          expect(response.status).to eq(200)
          expect(assigns[:project]).to eq(public_project)
          expect(assigns[:awards]).to match_array([public_award])
        end
      end

      context 'with a private project' do
        let!(:private_project) { create(:project, account: issuer.account, public: false) }
        let!(:private_award) { create(:award, award_type: create(:award_type, project: private_project)) }

        it 'sends you away' do
          get :index, params: { project_id: private_project.to_param }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(root_path)
        end
      end
    end

    describe 'checks policy' do
      before do
        allow(controller).to receive(:policy_scope).and_call_original
        allow(controller).to receive(:authorize).and_call_original
      end

      specify do
        login issuer.account

        get :index, params: { project_id: project.id }
        expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_contributions?)
      end

      specify do
        project.update_attributes(public: true)
        get :index, params: { project_id: project.id }
        expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_contributions?)
      end
    end
  end

  describe '#create' do
    let(:award_type) { create(:award_type, project: project) }

    before do
      login(issuer.account)
      request.env['HTTP_REFERER'] = "/projects/#{project.to_param}"
    end

    context 'logged in' do
      it 'records a slack award being created' do
        expect_any_instance_of(Award).to receive(:send_award_notifications)
        allow_any_instance_of(Award).to receive(:ethereum_issue_ready?) { true }

        expect do
          post :create, params: {
            project_id: project.to_param, award: {
              uid: receiver.uid,
              award_type_id: award_type.to_param,
              quantity: 1.5,
              description: 'This rocks!!11',
              channel_id: project.channels.first.id
            }
          }
          expect(response.status).to eq(302)
        end.to change { project.awards.count }.by(1)

        expect(response).to redirect_to(project_path(project))
        expect(flash[:notice]).to eq("Successfully sent award to #{receiver.account.decorate.name}")

        award = Award.last
        expect(award.award_type).to eq(award_type)
        expect(award.account).to eq(receiver.account)
        expect(award.description).to eq('This rocks!!11')
        expect(award.quantity).to eq(1.5)
        expect(EthereumTokenIssueJob.jobs.first['args']).to eq([award.id])
      end

      it 'records a discord award being created' do
        expect_any_instance_of(Award).to receive(:send_award_notifications)
        allow_any_instance_of(Account).to receive(:ethereum_issue_ready?) { true }

        stub_discord_channels
        channel = project.channels.create(team: discord_team, channel_id: 'channel_id', name: 'discord_channel')

        expect do
          post :create, params: {
            project_id: project.to_param, award: {
              uid: receiver_discord.uid,
              award_type_id: award_type.to_param,
              quantity: 1.5,
              description: 'This rocks!!11',
              channel_id: channel.id
            }
          }
          expect(response.status).to eq(302)
        end.to change { project.awards.count }.by(1)

        expect(response).to redirect_to(project_path(project))
        expect(flash[:notice]).to eq("Successfully sent award to #{receiver.account.decorate.name}")

        award = Award.last
        expect(award.discord?).to be_truthy
        expect(award.award_type).to eq(award_type)
        expect(award.account).to eq(receiver.account)
        expect(award.description).to eq('This rocks!!11')
        expect(award.quantity).to eq(1.5)
      end

      it "renders error if you specify a award type that doesn't belong to a project" do
        stub_request(:post, 'https://slack.com/api/users.info')
          .with(body: { 'token' => 'slack token', 'user' => 'receiver id' })
          .to_return(status: 200, body: File.read(Rails.root.join('spec', 'fixtures', 'users_info_response.json')), headers: {})
        expect_any_instance_of(Account).not_to receive(:send_award_notifications)
        expect do
          post :create, params: {
            project_id: project.to_param, award: {
              uid: 'receiver id',
              award_type_id: create(:award_type, amount: 10000, project: create(:project, maximum_tokens: 100_000, maximum_royalties_per_month: 25000)).to_param,
              description: 'I am teh haxor',
              channel_id: project.channels.first.id
            }
          }
          expect(response.status).to eq(302)
        end.not_to change { project.awards.count }
        expect(flash[:error]).to eq('Failed sending award - Not authorized')
      end

      it 'redirects back to projects show if error saving' do
        expect do
          post :create, params: {
            project_id: project.to_param, award: {
              uid: receiver.uid,
              description: 'This rocks!!11'
            }
          }
          expect(response.status).to eq(302)
        end.not_to change { project.awards.count }

        expect(response).to redirect_to(project_path(project))
        expect(flash[:error]).to eq('Failed sending award - missing award type')
      end
    end
  end

  describe '#confirm' do
    let!(:award) { create(:award, award_type: create(:award_type, project: project), issuer: issuer.account, account: nil, email: 'receiver@test.st', confirm_token: '1234') }

    it 'redirect_to login page' do
      get :confirm, params: { token: 1234 }
      expect(response).to redirect_to(new_session_path)
      expect(session[:award_token]).to eq '1234'
    end

    it 'redirect_to show error for invalid token' do
      login receiver.account
      get :confirm, params: { token: 12345 }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq 'Invalid award token!'
    end

    it 'add awardto account' do
      login receiver.account
      get :confirm, params: { token: 1234 }
      expect(response).to redirect_to(project_path(award.project))
      expect(award.reload.account_id).to eq receiver.account_id
    end
  end
end
