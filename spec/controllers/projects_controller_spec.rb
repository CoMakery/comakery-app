require 'rails_helper'

describe ProjectsController do
  let!(:team) { create :team, name: 'test-team' }
  let!(:authentication) { create(:authentication) }
  let!(:account) { authentication.account }

  let!(:account1) { create :account }
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:authentication1) { create(:authentication, account: account) }

  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:issuer) { create(:authentication) }
  let!(:issuer_discord) { create(:authentication, account: issuer.account, provider: 'discord') }
  let!(:receiver) { create(:authentication, account: create(:account)) }
  let!(:wallet) { create(:wallet, account: receiver.account, address: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367', _blockchain: :ethereum_ropsten) }
  let!(:receiver_discord) { create(:authentication, account: receiver.account, provider: 'discord') }
  let!(:other_auth) { create(:authentication) }
  let!(:different_team_account) { create(:authentication) }

  let(:project) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'eth', _blockchain: :ethereum_ropsten)) }

  let!(:token) { FactoryBot.create(:token) }
  let!(:mission) { FactoryBot.create(:mission, name: 'mission1', token_id: token.id) }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team authentication1
    login(account)
    stub_slack_channel_list
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
    let!(:admin_project) { create(:project, visibility: 'public_listed', title: 'admin project', mission_id: mission.id) }
    let!(:archived_project) { create(:project, visibility: 'archived', title: 'archived project', account: account, mission_id: mission.id) }
    let!(:unlisted_project) { create(:project, account: account, visibility: 'member_unlisted', title: 'unlisted project', mission_id: mission.id) }
    let!(:member_project) { create(:project, account: account, visibility: 'member', title: 'member project', mission_id: mission.id) }
    let!(:other_member_project) { create(:project, account: account1, visibility: 'member', title: 'other member project', mission_id: mission.id) }
    let!(:project_role) { create(:project_role, account: account) } # by default it will create project from mom.rb which will be Uber for Cats

    before do
      admin_project.project_admins << account
    end

    describe '#login' do
      it 'returns your private projects, and public projects that *do not* belong to you' do
        expect(TopContributors).to receive(:call).exactly(4).times.and_return(double(success?: true, contributors: {}))
        other_member_project.channels.create(team: team, channel_id: 'general')

        get :landing
        expect(response.status).to eq(200)
        expect(assigns[:my_projects].map(&:title)).to match_array(['public project', 'admin project', 'unlisted project', 'member project'])
        expect(assigns[:archived_projects].map(&:title)).to match_array(['archived project'])
        expect(assigns[:team_projects].map(&:title)).to match_array(['other member project'])
        expect(assigns[:involved_projects].map(&:title)).to match_array(['Uber for Cats'])
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
      before do
        session[:account_id] = nil
        get :new
      end

      it 'redirects you somewhere pretty' do
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_account_url)
      end
    end

    context 'when logged in with unconfirmed account' do
      let!(:account1) { create :account, email_confirm_token: '123' }

      before do
        login account1
        get :new
      end

      it 'redirects to home page' do
        expect(response.status).to eq(302)
        expect(response).to redirect_to(show_account_url)
      end
    end

    context 'when slack returns successful api calls' do
      render_views

      let(:expected_props) do
        {
          csrf_token: instance_of(String),
          decimal_places: Token.select(:id, :decimal_places),
          discord_bot_url: nil,
          discord_enabled: false,
          form_action: 'POST',
          form_url: projects_path,
          is_whitelabel: false,
          license_url: contribution_licenses_path(type: 'CP'),
          mission_for_header: nil,
          missions: { 'No Mission' => '', 'mission1' => mission.id },
          project: assigns(:project).serializable_hash.merge(
            {
              mission_id: nil,
              token_id: nil,
              github_url: assigns(:project).github_url,
              documentation_url: assigns(:project).documentation_url,
              getting_started_url: assigns(:project).getting_started_url,
              governance_url: assigns(:project).governance_url,
              funding_url: assigns(:project).funding_url,
              video_conference_url: assigns(:project).video_conference_url,
              url: unlisted_project_url(assigns(:project).long_id, protocol: :https)
            }.as_json
          ),
          project_for_header: { image_url: instance_of(String) },
          slack_enabled: true,
          teams: [
            {
              channels: [{ channel: 'a-channel-name', channel_id: 'a-channel-name' }],
              discord: false, team: '[slack] test-team', team_id: team.id.to_s
            },
            {
              channels: [{ channel: 'a-channel-name', channel_id: 'a-channel-name' }],
              discord: false, team: '[slack] test-team', team_id: team.id.to_s
            }
          ],
          terms_readonly: nil,
          tokens: { 'No Token' => '', token.name => token.id },
          visibilities: Project.visibilities.keys
        }
      end
      let(:get_image_variant_path_context) { double(:context, path: 'some_image_path') }

      before do
        allow(GetImageVariantPath).to receive(:call).and_return(get_image_variant_path_context)

        get :new
      end

      it 'works' do
        expect(response.status).to eq(200)
        expect(assigns[:project]).to be_a_new_record
        expect(assigns[:project]).to be_public
        expect(assigns[:props]).to match expected_props
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
      expect(project.square_image.attached?).to eq(true)
      expect(project.panoramic_image.attached?).to eq(true)
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

      expect(JSON.parse(response.body)['message']).to eq("Title can't be blank")
      project = assigns[:project]

      expect(project.description).to eq('Project description here')
      expect(project.square_image.attached?).to eq(true)
      expect(project.panoramic_image.attached?).to eq(true)
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
    let!(:token_unlisted) { FactoryBot.create(:token, unlisted: true) }
    let!(:cat_project) do
      FactoryBot.create :project,
                        visibility: :member, token: token, title: 'Cats',
                        description: 'Cats with lazers', account: account, mission_id: mission.id
    end
    let!(:dog_project) do
      FactoryBot.create :project,
                        visibility: :member, token: token, title: 'Dogs',
                        description: 'Dogs with donuts', account: account, mission_id: mission.id
    end
    let!(:yak_project) do
      FactoryBot.create :project,
                        visibility: :member, token: token, title: 'Yaks',
                        description: 'Yaks with parser generaters', account: account,
                        mission_id: mission.id
    end
    let!(:fox_project) do
      FactoryBot.create :project,
                        visibility: :member, token: token_unlisted, title: 'Foxes',
                        description: 'Foxes with boxes', account: account, mission_id: mission.id
    end
    let!(:channel) { FactoryBot.create :channel, :discord, project: cat_project, team: team }

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
        expect(assigns[:projects].map(&:title)).to eq(%w[Cats Dogs Yaks Foxes])
        expect(assigns[:project_contributors].keys).to eq([cat_project, dog_project, yak_project])
      end

      it 'allows searching' do
        get :index, params: { q: { title_or_description_or_token_name_or_mission_name_cont: 'cats' } }

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(['Cats'])
      end

      it 'do not show any non-public projects for not login user' do
        logout
        get :index
        expect(assigns[:projects].map(&:title)).to eq []
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

      it 'includes only whitelabel projects' do
        whitelabel_mission = create(:active_whitelabel_mission)
        whitelabel_project = create(:project, visibility: :public_listed, mission: whitelabel_mission)
        project = create(:project, visibility: :public_listed)

        get :index
        expect(assigns[:projects]).to include(whitelabel_project)
        expect(assigns[:projects]).not_to include(project)
      end

      it 'doesnt include whitelabel projects' do
        whitelabel_mission = create(:mission, whitelabel: true)
        whitelabel_project = create(:project, visibility: :public_listed, mission: whitelabel_mission)

        get :index
        expect(assigns[:projects]).not_to include(whitelabel_project)
      end
    end

    describe '#edit' do
      let(:expected_props) do
        {
          csrf_token: instance_of(String),
          decimal_places: Token.select(:id, :decimal_places),
          discord_bot_url: nil,
          discord_enabled: false,
          form_action: 'PATCH',
          form_url: project_path(cat_project),
          is_whitelabel: false,
          license_url: contribution_licenses_path(type: 'CP'),
          mission_for_header: {
            image_url: 'some_image_path', name: 'mission1', url: mission_path(mission)
          },
          missions: { 'No Mission' => '', 'mission1' => mission.id },
          project: assigns(:project).serializable_hash.merge(
            {
              mission_id: mission.id,
              token_id: token.id,
              channels: [
                {
                  channel_id: channel.channel_id,
                  id: channel.id,
                  name_with_provider: channel.name_with_provider,
                  team_id: team.id.to_s
                }
              ],
              panoramic_image_url: 'some_image_path',
              square_image_url: 'some_image_path',
              github_url: assigns(:project).github_url,
              documentation_url: assigns(:project).documentation_url,
              getting_started_url: assigns(:project).getting_started_url,
              governance_url: assigns(:project).governance_url,
              funding_url: assigns(:project).funding_url,
              video_conference_url: assigns(:project).video_conference_url,
              url: unlisted_project_url(assigns(:project).long_id)
            }.as_json
          ),
          project_for_header: cat_project.decorate.header_props(account),
          slack_enabled: true,
          teams: [
            {
              channels: [{ channel: 'a-channel-name', channel_id: 'a-channel-name' }],
              discord: false, team: '[slack] test-team', team_id: team.id.to_s
            },
            {
              channels: [{ channel: 'a-channel-name', channel_id: 'a-channel-name' }],
              discord: false, team: '[slack] test-team', team_id: team.id.to_s
            }
          ],
          terms_readonly: false,
          tokens: { 'No Token' => '', token.name => token.id },
          visibilities: Project.visibilities.keys
        }
      end
      let(:get_image_variant_path_context) { double(:context, path: 'some_image_path') }

      before do
        allow(GetImageVariantPath).to receive(:call).and_return(get_image_variant_path_context)
      end

      it 'works' do
        get :edit, params: { id: cat_project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(cat_project)
        expect(assigns[:props]).to match expected_props
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
      let(:another_account) { FactoryBot.create(:account) }

      let!(:cat_project_award) do
        FactoryBot.create :award,
                          account: account, amount: 200, status: :ready,
                          award_type: FactoryBot.create(:award_type, state: :public, project: cat_project),
                          transfer_type: transfer_type
      end
      let!(:cat_project_award2) do
        FactoryBot.create :award,
                          account: another_account, amount: 200, status: :ready,
                          award_type: FactoryBot.create(:award_type, state: :public, project: cat_project),
                          transfer_type: transfer_type
      end
      let!(:transfer_type) { FactoryBot.create :transfer_type, project: cat_project }

      let(:expected_project_props) do
        cat_project.as_json(only: %i[id title require_confidentiality display_team whitelabel]).merge(
          description_html: cat_project.description,
          show_contributions: true,
          square_image_url: instance_of(String),
          panoramic_image_url: instance_of(String),
          video_id: cat_project.video_id,
          token_percentage: cat_project.decorate.percent_awarded_pretty,
          maximum_tokens: cat_project.maximum_tokens,
          awarded_tokens: cat_project.decorate.total_awarded_pretty,
          team_size: cat_project.decorate.team_size,
          team: [instance_of(Hash)],
          chart_data: [],
          stats: cat_project.stats
        )
      end

      context 'when on team' do
        context 'when team leader' do
          let(:expected_props) do
            {
              whitelabel: false,
              tasks_by_specialty: instance_of(Array),
              follower: true,
              project_data: expected_project_props,
              token_data: {
                _token_type: token._token_type, image_url: nil, name: token.name,
                symbol: token.symbol
              }.as_json,
              csrf_token: instance_of(String),
              my_tasks_path: my_tasks_path(project_id: cat_project.id),
              editable: true,
              project_for_header: cat_project.decorate.header_props(account),
              mission_for_header: mission.decorate.header_props
            }
          end

          it 'allows team members to view projects and assigns awardable accounts from slack api and db and de-dups' do
            login(account)
            get :show, params: { id: cat_project.to_param }

            expect(response.code).to eq '200'
            expect(assigns(:project)).to eq cat_project
            expect(assigns[:award]).to be_new_record
            expect(assigns[:can_award]).to eq true
            expect(assigns[:props]).to match expected_props
          end
        end

        context 'when contributor' do
          let(:expected_props) do
            {
              whitelabel: false,
              tasks_by_specialty: instance_of(Array),
              follower: true,
              project_data: expected_project_props,
              token_data: {
                _token_type: token._token_type, image_url: nil, name: token.name,
                symbol: token.symbol
              }.as_json,
              csrf_token: instance_of(String),
              my_tasks_path: my_tasks_path(project_id: cat_project.id),
              editable: false,
              project_for_header: cat_project.decorate.header_props(another_account),
              mission_for_header: mission.decorate.header_props
            }
          end

          it 'allows team members to view projects and assigns awardable accounts from slack api and db and de-dups' do
            login(another_account)
            get :show, params: { id: cat_project.to_param }

            expect(response.code).to eq '200'
            expect(assigns(:project)).to eq cat_project
            expect(assigns[:award]).to be_new_record
            expect(assigns[:can_award]).to eq false
            expect(assigns[:props]).to match expected_props
          end
        end
      end

      context 'when with invitation' do
        let(:invite) { FactoryBot.create :project_invite, role: 'admin' }

        before { session[:project_invite_id] = invite.id }

        it 'should respond with project data and correct notice' do
          login(account)
          get :show, params: { id: cat_project.to_param }

          expect(response.code).to eq '200'
          expect(assigns(:project)).to eq cat_project
          expect(assigns[:award]).to be_new_record
          expect(assigns[:can_award]).to eq true
          expect(flash[:notice])
            .to eq 'You have successfully joined the project with the admin role'

          expect(session.key?(:project_invite_id)).to eq false
        end
      end
    end

    describe 'redirect_for_whitelabel' do
      let!(:mission) { create(:active_whitelabel_mission) }
      let!(:project) { create(:project, mission: mission, visibility: :public_listed) }
      let!(:project_unlisted) { create(:project, mission: mission, visibility: :public_unlisted) }
      let!(:project_confidential) { create(:project, mission: mission, visibility: :public_listed, require_confidentiality: true) }
      let!(:project_unlisted_confidential) { create(:project, mission: mission, visibility: :public_unlisted, require_confidentiality: true) }

      it 'redirects #show to transfers' do
        get :show, params: { id: project.to_param }
        expect(response).to redirect_to(project_dashboard_transfers_path(project))
      end

      it 'redirects #unlisted to transfers' do
        get :unlisted, params: { long_id: project_unlisted.long_id }
        expect(response).to redirect_to(project_dashboard_transfers_path(project_unlisted))
      end

      it 'redirects #show to batches ' do
        get :show, params: { id: project_confidential.to_param }
        expect(response).to redirect_to(project_award_types_path(project_confidential))
      end

      it 'redirects #unlisted to batches ' do
        get :unlisted, params: { long_id: project_unlisted_confidential.long_id }
        expect(response).to redirect_to(project_award_types_path(project_unlisted_confidential))
      end
    end
  end
end
