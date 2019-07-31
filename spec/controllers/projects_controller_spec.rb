require 'rails_helper'

describe ProjectsController do
  let!(:team) { create :team }
  let!(:authentication) { create(:authentication) }
  let!(:account) { authentication.account }

  let!(:account1) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:authentication1) { create(:authentication, account: account) }

  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:issuer) { create(:authentication) }
  let!(:issuer_discord) { create(:authentication, account: issuer.account, provider: 'discord') }
  let!(:receiver) { create(:authentication, account: create(:account, ethereum_wallet: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367')) }
  let!(:receiver_discord) { create(:authentication, account: receiver.account, provider: 'discord') }
  let!(:other_auth) { create(:authentication) }
  let!(:different_team_account) { create(:authentication) }

  let(:project) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'erc20')) }

  let!(:token) { create(:token) }
  let!(:mission) { create(:mission, token_id: token.id) }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team authentication1
    login(account)
    stub_slack_channel_list
  end

  describe '#awards' do
    let!(:award) { create(:award, award_type: create(:award_type, project: project), account: other_auth.account) }
    let!(:different_project_award) { create(:award, award_type: create(:award_type, project: create(:project)), account: other_auth.account) }

    context 'when logged in' do
      before { login(issuer.account) }

      it 'shows awards for current project' do
        get :awards, params: { id: project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(project)
        expect(assigns[:awards]).to match_array([award])
      end

      it 'shows metamask awards' do
        stub_token_symbol
        project.token.update ethereum_contract_address: '0x' + 'a' * 40
        get :awards, params: { id: project.to_param }

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
          get :awards, params: { id: public_project.id }

          expect(response.status).to eq(200)
          expect(assigns[:project]).to eq(public_project)
          expect(assigns[:awards]).to match_array([public_award])
        end
      end

      context 'with a private project' do
        let!(:private_project) { create(:project, account: issuer.account, public: false) }
        let!(:private_award) { create(:award, award_type: create(:award_type, project: private_project)) }

        it 'sends you away' do
          get :awards, params: { id: private_project.to_param }

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

        get :awards, params: { id: project.id }
        expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_contributions?)
      end

      specify do
        project.public_listed!
        get :awards, params: { id: project.id }
        expect(controller).to have_received(:authorize).with(controller.instance_variable_get('@project'), :show_contributions?)
      end
    end
  end

  describe '#unlisted' do
    let!(:public_unlisted_project) { create(:project, account: account, visibility: 'public_unlisted', title: 'Unlisted Project', mission_id: mission.id) }
    let!(:member_unlisted_project) { create(:project, account: account, visibility: 'member_unlisted', title: 'Unlisted Project', mission_id: mission.id) }
    let!(:normal_project) { create :project, account: account, mission_id: mission.id }
    let!(:account2) { create :account }
    let!(:authentication2) { create(:authentication, account: account2) }

    it 'everyone can access public unlisted project via long id' do
      get :unlisted, params: { long_id: public_unlisted_project.long_id }
      expect(response.code).to eq '200'
      expect(assigns(:project)).to eq public_unlisted_project
    end

    it 'other team member cannot access member unlisted project' do
      login account2
      get :unlisted, params: { long_id: member_unlisted_project.long_id }
      expect(response).to redirect_to(root_url)
    end

    it 'team member can access member unlisted project' do
      team.build_authentication_team authentication2
      login account2
      get :unlisted, params: { long_id: member_unlisted_project.long_id }
      expect(response.code).to eq '302'
      expect(assigns(:project)).to eq member_unlisted_project
    end

    it 'redirect_to project/id page for normal project' do
      login account
      get :unlisted, params: { long_id: normal_project.long_id }
      expect(response).to redirect_to(project_path(normal_project))
    end

    it 'project owner can access unlisted project by id' do
      login public_unlisted_project.account
      get :show, params: { id: public_unlisted_project.id }
      expect(response.code).to eq '200'
      expect(assigns(:project)).to eq public_unlisted_project
    end

    it 'not project owner cannot access unlisted project by id' do
      login create(:account)
      get :show, params: { id: public_unlisted_project.id }
      expect(response).to redirect_to('/')
    end

    it 'redirects to 404 when long id is not valid' do
      get :unlisted, params: { long_id: 'wrong' }
      expect(response).to redirect_to('/404.html')
    end
  end

  describe '#landing' do
    let!(:public_project) { create(:project, visibility: 'public_listed', title: 'public project', account: account, mission_id: mission.id) }
    let!(:archived_project) { create(:project, visibility: 'archived', title: 'archived project', account: account, mission_id: mission.id) }
    let!(:unlisted_project) { create(:project, account: account, visibility: 'member_unlisted', title: 'unlisted project', mission_id: mission.id) }
    let!(:member_project) { create(:project, account: account, visibility: 'member', title: 'member project', mission_id: mission.id) }
    let!(:other_member_project) { create(:project, account: account1, visibility: 'member', title: 'other member project', mission_id: mission.id) }

    describe '#login' do
      it 'returns your private projects, and public projects that *do not* belong to you' do
        expect(TopContributors).to receive(:call).exactly(3).times.and_return(double(success?: true, contributors: {}))
        other_member_project.channels.create(team: team, channel_id: 'general')

        get :landing
        expect(response.status).to eq(200)
        expect(assigns[:my_projects].map(&:title)).to match_array(['public project', 'unlisted project', 'member project'])
        expect(assigns[:archived_projects].map(&:title)).to match_array(['archived project'])
        expect(assigns[:team_projects].map(&:title)).to match_array(['other member project'])
      end
    end
  describe 'logged out'
    it 'redirect to signup page if you are not logged in' do
      logout
      get :landing
      expect(response.status).to eq(302)
      expect(response).to redirect_to(new_account_url)
    end
  end

  describe '#new' do
    context 'when not logged in' do
      it 'redirects you somewhere pretty' do
        session[:account_id] = nil

        get :new

        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_account_url)
      end
    end

    context 'when logged in with unconfirmed account' do
      let!(:account1) { create :account, email_confirm_token: '123' }

      it 'redirects to home page' do
        login account1
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when slack returns successful api calls' do
      render_views

      it 'works' do
        get :new

        expect(response.status).to eq(200)
        expect(assigns[:project]).to be_a_new_record
        expect(assigns[:project]).not_to be_public
      end
    end
  end

  describe '#create' do
    render_views

    it 'when valid, creates a project and associates it with the current account' do
      expect do
        post :create, params: {
          project: {
            title: 'Project title here',
            description: 'Project description here',
            square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            tracker: 'http://github.com/here/is/my/tracker',
            contributor_agreement_url: 'http://docusign.com/here/is/my/signature',
            video_url: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0',
            slack_channel: 'slack_channel',
            maximum_tokens: '150',
            legal_project_owner: 'legal project owner',
            payment_type: 'project_token',
            token_id: create(:token).id,
            mission_id: create(:mission).id,
            require_confidentiality: false,
            exclusive_contributions: false,
            visibility: 'member'
          }
        }
        expect(response.status).to eq(200)
      end.to change { Project.count }.by(1)

      project = Project.last
      expect(project.title).to eq('Project title here')
      expect(project.description).to eq('Project description here')
      expect(project.square_image).to be_a(Refile::File)
      expect(project.panoramic_image).to be_a(Refile::File)
      expect(project.tracker).to eq('http://github.com/here/is/my/tracker')
      expect(project.contributor_agreement_url).to eq('http://docusign.com/here/is/my/signature')
      expect(project.video_url).to eq('https://www.youtube.com/watch?v=Dn3ZMhmmzK0')
      expect(project.maximum_tokens).to eq(150)
      expect(project.account_id).to eq(account.id)
    end

    it 'when invalid, returns 422' do
      expect do
        expect do
          post :create, params: {
            project: {
              # title: "Project title here",
              description: 'Project description here',
              square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              tracker: 'http://github.com/here/is/my/tracker',
              token_id: create(:token).id,
              mission_id: create(:mission).id,
              require_confidentiality: false,
              exclusive_contributions: false,
              visibility: 'member',
              award_types_attributes: [
                { name: 'Small Award', amount: 1000, community_awardable: true },
                { name: 'Big Award', amount: 2000 },
                { name: '', amount: '' }
              ]
            }
          }
          expect(response.status).to eq(422)
        end.not_to change { Project.count }
      end.not_to change { AwardType.count }

      expect(JSON.parse(response.body)['message']).to eq("Title can't be blank, Legal project owner can't be blank")
      project = assigns[:project]

      expect(project.description).to eq('Project description here')
      expect(project.square_image).to be_a(Refile::File)
      expect(project.panoramic_image).to be_a(Refile::File)
      expect(project.tracker).to eq('http://github.com/here/is/my/tracker')
      expect(project.account_id).to eq(account.id)
    end

    it 'when duplicated, redirects with error' do
      expect do
        post :create, params: {
          project: {
            title: 'Project title here',
            description: 'Project description here',
            square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            tracker: 'http://github.com/here/is/my/tracker',
            contributor_agreement_url: 'http://docusign.com/here/is/my/signature',
            video_url: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0',
            slack_channel: 'slack_channel',
            maximum_tokens: '150',
            legal_project_owner: 'legal project owner',
            payment_type: 'project_token',
            token_id: create(:token).id,
            mission_id: create(:mission).id,
            long_id: '0',
            require_confidentiality: false,
            exclusive_contributions: false,
            visibility: 'member'
          }
        }
        expect(response.status).to eq(200)
      end.to change { Project.count }.by(1)

      expect do
        post :create, params: {
          project: {
            title: 'Project title here',
            description: 'Project description here',
            square_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            panoramic_image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            tracker: 'http://github.com/here/is/my/tracker',
            contributor_agreement_url: 'http://docusign.com/here/is/my/signature',
            video_url: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0',
            slack_channel: 'slack_channel',
            maximum_tokens: '150',
            legal_project_owner: 'legal project owner',
            payment_type: 'project_token',
            token_id: create(:token).id,
            mission_id: create(:mission).id,
            long_id: '0',
            require_confidentiality: false,
            exclusive_contributions: false,
            visibility: 'member'
          }
        }
        expect(response.status).to eq(422)
      end.not_to change { Project.count }

      expect(JSON.parse(response.body)['message']).to eq("Long identifier can't be blank or not unique")
    end
  end

  describe '#update_status' do
    let!(:project) { create(:project, mission_id: mission.id) }

    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        post :update_status, params: { project_id: project.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_account_url)
      end
    end

    context 'when logged in with admin flag' do
      it 'update valid project status' do
        login admin_account
        post :update_status, params: { project_id: project.id, status: 'active' }
        expect(response.status).to eq(200)
      end

      it 'renders error with invalid status' do
        login admin_account
        post :update_status, params: { project_id: project.id, status: 'archived' }
        expect(response.status).to eq(422)
      end
    end
  end

  context 'with a project' do
    let!(:token) { create(:token) }
    let!(:token_unlisted) { create(:token, unlisted: true) }
    let!(:cat_project) { create(:project, title: 'Cats', description: 'Cats with lazers', account: account, mission_id: mission.id) }
    let!(:dog_project) { create(:project, title: 'Dogs', description: 'Dogs with donuts', account: account, mission_id: mission.id) }
    let!(:yak_project) { create(:project, title: 'Yaks', description: 'Yaks with parser generaters', account: account, mission_id: mission.id) }
    let!(:fox_project) { create(:project, token: token_unlisted, title: 'Foxes', description: 'Foxes with boxes', account: account, mission_id: mission.id) }

    describe '#index' do
      let!(:cat_project_award) { create(:award, account: create(:account), amount: 200, award_type: create(:award_type, project: cat_project), created_at: 2.days.ago, updated_at: 2.days.ago) }
      let!(:dog_project_award) { create(:award, account: create(:account), amount: 100, award_type: create(:award_type, project: dog_project), created_at: 1.day.ago, updated_at: 1.day.ago) }
      let!(:yak_project_award) { create(:award, account: create(:account), amount: 300, award_type: create(:award_type, project: yak_project), created_at: 3.days.ago, updated_at: 3.days.ago) }

      before do
        expect(TopContributors).to receive(:call).and_return(double(success?: true, contributors: { cat_project => [], dog_project => [], yak_project => [] }))
      end

      include ActionView::Helpers::DateHelper

      it 'lists the projects ordered by most recently modify date' do
        get :index

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(%w[Yaks Dogs Cats Foxes])
        expect(assigns[:project_contributors].keys).to eq([cat_project, dog_project, yak_project])
      end

      it 'allows querying based on the title of the project, ignoring case' do
        get :index, params: { query: 'cats' }

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(['Cats'])
      end

      it 'allows querying based on the title or description of the project, ignoring case' do
        get :index, params: { query: 'o' }

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(%w[Dogs Foxes])
      end

      it 'only show public projects for not login user' do
        logout
        fox_project.public_listed!
        get :index
        expect(assigns[:projects].map(&:title)).to eq(['Foxes'])
      end

      it 'dont show archived projects for not login user' do
        logout
        cat_project.archived!
        fox_project.public_listed!
        get :index
        expect(assigns[:projects].map(&:title)).to eq(['Foxes'])
      end
    end

    describe '#edit' do
      it 'works' do
        get :edit, params: { id: cat_project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(cat_project)
      end

      it 'doesnt include unlisted tokens' do
        get :edit, params: { id: cat_project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:tokens][token.name]).to eq(token.id)
        expect(assigns[:tokens][token_unlisted.name]).to be_nil
      end

      it 'includes unlisted token associated with project' do
        get :edit, params: { id: fox_project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:tokens][token_unlisted.name]).to eq(token_unlisted.id)
      end
    end

    describe '#update' do
      it 'updates a project' do
        expect do
          put :update, params: {
            id: cat_project.to_param,
            project: {
              title: 'updated Project title here',
              description: 'updated Project description here',
              tracker: 'http://github.com/here/is/my/tracker/updated'
            }
          }
          expect(response.status).to eq(200)
        end.to change { Project.count }.by(0)

        cat_project.reload
        expect(cat_project.title).to eq('updated Project title here')
        expect(cat_project.description).to eq('updated Project description here')
        expect(cat_project.tracker).to eq('http://github.com/here/is/my/tracker/updated')
      end

      context 'with rendered views' do
        render_views
        it 'returns 422 when updating fails' do
          expect do
            put :update, params: {
              id: cat_project.to_param,
              project: {
                title: '',
                description: 'updated Project description here',
                tracker: 'http://github.com/here/is/my/tracker/updated',
                legal_project_owner: 'legal project owner',
                payment_type: 'project_token'
              }
            }
            expect(response.status).to eq(422)
          end.not_to change { Project.count }

          project = assigns[:project]
          expect(JSON.parse(response.body)['message']).to eq("Title can't be blank")
          expect(project.title).to eq('')
          expect(project.description).to eq('updated Project description here')
          expect(project.tracker).to eq('http://github.com/here/is/my/tracker/updated')
        end
      end
    end

    describe '#show' do
      let!(:awardable_auth) { create(:authentication) }

      context 'when on team' do
        it 'allows team members to view projects and assigns awardable accounts from slack api and db and de-dups' do
          login(account)
          get :show, params: { id: cat_project.to_param }

          # expect(response.code).to eq '200'
          expect(assigns(:project)).to eq cat_project
          expect(assigns[:award]).to be_new_record
          expect(assigns[:can_award]).to eq(true)
        end
      end
    end
  end
end
