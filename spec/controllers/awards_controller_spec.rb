require 'rails_helper'
require 'controllers/unavailable_for_lockup_token_spec'

RSpec.describe AwardsController, type: :controller do
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:issuer) { create(:authentication) }
  let!(:issuer_discord) { create(:authentication, account: issuer.account, provider: 'discord') }
  let!(:receiver) { create(:authentication, account: create(:account)) }
  let!(:receiver_discord) { create(:authentication, account: receiver.account, provider: 'discord') }
  let!(:other_auth) { create(:authentication) }
  let!(:different_team_account) { create(:authentication) }
  let!(:project) { create(:project, account: issuer.account, visibility: :public_listed, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'erc20', contract_address: build(:ethereum_contract_address), _blockchain: :ethereum_ropsten)) }
  let!(:award_type) { create(:award_type, project: project) }
  let!(:wallet) do
    create :wallet, account: receiver.account, _blockchain: project.token&._blockchain, address: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367'
  end

  let(:now) { Time.zone.local(2021, 6, 3, 15) }
  let(:header_props) { double(:header_props) }
  let(:get_image_variant_path_context) { double(:context, path: 'some_image_path') }

  before do
    Timecop.freeze(now)

    stub_discord_channels

    allow(GetImageVariantPath).to receive(:call).and_return(get_image_variant_path_context)
    allow_any_instance_of(AwardsController)
      .to receive(:form_authenticity_token).and_return('some_csrf_token')
  end

  shared_context 'with specialties' do
    let!(:specialty1) { FactoryBot.create :specialty, name: 'Audio Or Video Production' }
    let!(:specialty2) { FactoryBot.create :specialty, name: 'Community Development' }
    let!(:specialty3) { FactoryBot.create :specialty, name: 'Data Gathering' }
    let!(:specialty4) { FactoryBot.create :specialty, name: 'Marketing & Social' }
    let!(:specialty5) { FactoryBot.create :specialty, name: 'Software Development' }
    let!(:specialty6) { FactoryBot.create :specialty, name: 'Design' }
    let!(:specialty7) { FactoryBot.create :specialty, name: 'Writing' }
    let!(:specialty8) { FactoryBot.create :specialty, name: 'Research' }

    let(:expected_specialities_list) do
      {
        'Audio Or Video Production' => specialty1.id, 'Community Development' => specialty2.id,
        'Data Gathering' => specialty3.id, 'Marketing & Social' => specialty4.id,
        'Software Development' => specialty5.id, 'Design' => specialty6.id,
        'Writing' => specialty7.id, 'Research' => specialty8.id, 'General' => Specialty.default.id
      }
    end
  end

  describe '#index' do
    before do
      21.times { create(:award, award_type: award_type, account: issuer.account) }
      login(issuer.account)
    end

    it 'returns my tasks' do
      get :index
      expect(response.status).to eq(200)
    end

    it 'uses filtering' do
      get :index, params: { filter: 'started' }
      expect(response.status).to eq(200)
      expect(assigns[:props][:tasks].count).to eq(0)
    end

    it 'uses pagination' do
      get :index, params: { filter: 'submitted', page: '2' }
      expect(response.status).to eq(200)
      expect(assigns[:props][:tasks].count).to eq(1)
    end

    it 'redirects to 404 when provided with incorrect page' do
      get :index, params: { page: '3' }
      expect(response).to redirect_to('/404.html')
    end

    it 'sets project filter' do
      project = create(:project)
      get :index, params: { project_id: project.id }

      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
    end

    it 'do not show wl projects for main' do
      wl_mission = create :mission, whitelabel_domain: 'wl.test.host', whitelabel: true, whitelabel_api_public_key: build(:api_public_key), whitelabel_api_key: build(:api_key)
      wl_project = create :project, mission: wl_mission, title: 'WL project title'

      get :index, params: { project_id: wl_project.id }
      expect(response.status).to eq(200)
      expect(assigns[:project]).to be nil
    end

    it 'sets default project filter if user has no experience' do
      project = create(:project)
      ENV['DEFAULT_PROJECT_ID'] = project.id.to_s
      login(create(:account))

      get :index
      expect(response.status).to eq(200)
      expect(assigns[:project]).to eq(project)
    end

    it 'is unavailable_for_whitelabel' do
      create :active_whitelabel_mission

      get :index
      expect(response).to redirect_to(projects_url)
    end

    it 'doesnt include whitelabel tasks' do
      whitelabel_task = create(:award_ready, name: 'Task not visible because of white label')
      whitelabel_task.project.mission.update(whitelabel: true, whitelabel_domain: 'NOT.test.host')
      whitelabel_task.save!

      get :index
      expect(response.status).to eq(200)
      expect(assigns[:awards]).not_to include(whitelabel_task)
    end
  end

  describe '#show' do
    let(:award) { create(:award, award_type: award_type) }
    let(:account) { project.account.decorate }

    it_behaves_like 'unavailable_for_lockup_token' do
      let!(:award) { create(:award, award_type: award_type) }

      subject { get :show, params: { id: award.to_param, project_id: award.project.to_param, award_type_id: award.award_type.to_param } }
    end

    it 'shows member tasks to logged in members' do
      login(account)
      award.project.member!
      get :show, params: { id: award.to_param, project_id: award.project.to_param, award_type_id: award.award_type.to_param }
      expect(response.status).to eq(200)
      expect(assigns[:props][:account_name]).to eq(account.name)
    end

    it 'hides member tasks to logged in non members' do
      login(create(:account))
      award.project.member!
      get :show, params: { id: award.to_param, project_id: award.project.to_param, award_type_id: award.award_type.to_param }
      expect(response.status).to eq(302)
    end

    it 'shows public tasks to logged in users' do
      login(account)
      get :show, params: { id: award.to_param, project_id: award.project.to_param, award_type_id: award.award_type.to_param }
      expect(response.status).to eq(200)
      expect(assigns[:props][:account_name]).to eq(account.name)
    end

    it 'shows public tasks to not logged in users' do
      logout
      get :show, params: { id: award.to_param, project_id: award.project.to_param, award_type_id: award.award_type.to_param }
      expect(response.status).to eq(200)
      expect(assigns[:props][:account_name]).to eq(nil)
    end

    it 'does not show private tasks to not logged in users' do
      logout
      award.project.member!
      get :show, params: { id: award.to_param, project_id: award.project.to_param, award_type_id: award.award_type.to_param }
      expect(response.status).to eq(302)
    end
  end

  describe '#new' do
    let(:account) { FactoryBot.create(:account, created_at: now) }
    let(:transfer_type1) do
      FactoryBot.build(:transfer_type, project: nil, name: 'mint', created_at: now)
    end
    let(:transfer_type2) do
      FactoryBot.build(:transfer_type, project: nil, name: 'blah', created_at: now)
    end
    let(:transfer_type3) do
      FactoryBot.build(:transfer_type, project: nil, name: 'burn', created_at: now)
    end
    let(:token) { FactoryBot.create(:token, created_at: now, updated_at: now) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:mission) { FactoryBot.create(:mission, created_at: now) }
    let(:project) do
      FactoryBot.create :project, account: account, token: token, mission: mission, created_at: now,
                                  transfer_types: [transfer_type1, transfer_type2, transfer_type3]
    end
    let(:award_type) do
      FactoryBot.create(:award_type, project: project, created_at: now, updated_at: now)
    end
    let(:new_award) { award_type.awards.new }
    let(:timestamps_stub) { { 'created_at' => kind_of(Time), 'updated_at' => kind_of(Time) } }

    include_context 'with specialties'

    let(:expected_form_properties) do
      {
        task: new_award.serializable_hash.merge(image_url: get_image_variant_path_context.path),
        batch: award_type.serializable_hash,
        project: project.serializable_hash.merge(timestamps_stub),
        token: token.serializable_hash.merge(timestamps_stub),
        experience_levels: Award::EXPERIENCE_LEVELS,
        specialties: expected_specialities_list,
        types: { 'Blah' => transfer_type2.id },
        form_url: project_award_type_awards_path(project, award_type),
        form_action: 'POST',
        url_on_success: project_award_types_path,
        csrf_token: 'some_csrf_token',
        project_for_header: project.decorate.header_props(account),
        mission_for_header: {
          name: mission.name, image_url: get_image_variant_path_context.path,
          url: mission_path(mission)
        }
      }
    end

    before do
      allow(project).to receive(:header_props).with(account).and_return(header_props)

      login(account)
      get :new, params: { project_id: project.id, award_type_id: award_type.id }
    end

    it 'should respond with success' do
      expect(response.status).to eq 200
      expect(assigns[:props]).to match expected_form_properties
      expect(response).to render_template(:new)
    end
  end

  describe '#create' do
    let(:award_type) { create(:award_type, project: project) }

    before do
      login(issuer.account)
      request.env['HTTP_REFERER'] = "/projects/#{project.to_param}"
    end

    context 'logged in' do
      it 'creates task' do
        expect do
          post :create, params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            task: {
              name: 'none',
              description: 'none',
              amount: '100',
              why: 'none',
              requirements: 'none',
              proof_link: 'http://nil'
            }
          }
          expect(response.status).to eq(200)
          expect(response.media_type).to eq('application/json')
          expect(JSON.parse(response.body)['message']).to eq('Task created')
          expect(JSON.parse(response.body)['id']).to eq(project.awards.reload.last.id)
        end.to change { project.awards.count }.by(1)

        award = project.awards.last
        expect(award.award_type).to eq(award_type)
        expect(award.status).to eq('ready')
      end

      it 'returns an error' do
        expect do # rubocop:todo Lint/AmbiguousBlockAssociation
          post :create, params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            task: {
              name: '',
              amount: '100',
              description: 'none',
              why: 'none',
              requirements: 'none',
              proof_link: 'http://nil'
            }
          }
          expect(response.status).to eq(422)
          expect(response.media_type).to eq('application/json')
          expect(JSON.parse(response.body)['message']).to eq("Name can't be blank")
        end.not_to change { project.awards.count }
      end
    end
  end

  describe '#clone' do
    let(:account) { FactoryBot.create(:account, created_at: now) }
    let!(:transfer_type1) do
      FactoryBot.build(:transfer_type, project: nil, name: 'mint', created_at: now)
    end
    let!(:transfer_type2) do
      FactoryBot.build(:transfer_type, project: nil, name: 'blah', created_at: now)
    end
    let!(:transfer_type3) do
      FactoryBot.build(:transfer_type, project: nil, name: 'burn', created_at: now)
    end
    let(:token) { FactoryBot.create(:token, created_at: now) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:mission) { FactoryBot.create(:mission, created_at: now) }
    let(:project) do
      FactoryBot.create :project, account: account, token: token, mission: mission, created_at: now,
                                  transfer_types: [transfer_type1, transfer_type2, transfer_type3]
    end
    let(:award_type) { FactoryBot.create(:award_type, project: project, created_at: now) }
    let(:award) do
      FactoryBot.create :award, account: account, award_type: award_type,
                                transfer_type: transfer_type2, issuer: account, created_at: now
    end

    include_context 'with specialties'

    let(:expected_form_properties) do
      {
        task: award.serializable_hash.merge(
          image_url: get_image_variant_path_context.path, image_from_id: award.id
        ),
        batch: award_type.serializable_hash,
        project: project.serializable_hash,
        token: token.serializable_hash,
        experience_levels: Award::EXPERIENCE_LEVELS,
        specialties: expected_specialities_list,
        types: { 'Blah' => transfer_type2.id },
        form_url: project_award_type_awards_path(project, award_type),
        form_action: 'POST',
        url_on_success: project_award_types_path,
        csrf_token: 'some_csrf_token',
        project_for_header: project.decorate.header_props(account),
        mission_for_header: {
          name: mission.name, image_url: get_image_variant_path_context.path,
          url: mission_path(mission)
        }
      }
    end

    before do
      allow(project)
        .to receive(:header_props).with(account).and_return(header_props)

      login(account)
      get :clone, params: {
        project_id: project.id, award_type_id: award_type.id, award_id: award.id
      }
    end

    it 'should respond with success' do
      expect(response.status).to eq 200
      expect(assigns[:props]).to eq expected_form_properties
      expect(response).to render_template(:clone)
    end
  end

  describe '#edit' do
    let(:account) { FactoryBot.create(:account, created_at: now) }
    let(:transfer_type1) do
      FactoryBot.build(:transfer_type, project: nil, name: 'mint', created_at: now)
    end
    let(:transfer_type2) do
      FactoryBot.build(:transfer_type, project: nil, name: 'blah', created_at: now)
    end
    let(:transfer_type3) do
      FactoryBot.build(:transfer_type, project: nil, name: 'burn', created_at: now)
    end
    let(:token) { FactoryBot.create(:token, created_at: now) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:mission) { FactoryBot.create(:mission, created_at: now) }
    let(:project) do
      FactoryBot.create :project, account: account, token: token, mission: mission, created_at: now,
                                  transfer_types: [transfer_type1, transfer_type2, transfer_type3]
    end
    let(:award_type) { FactoryBot.create(:award_type, project: project, created_at: now) }
    let(:award) do
      FactoryBot.create :award, account: account, award_type: award_type,
                                transfer_type: transfer_type2, issuer: account, created_at: now
    end

    include_context 'with specialties'

    let(:expected_form_properties) do
      {
        task: award.serializable_hash.merge(image_url: get_image_variant_path_context.path),
        batch: award_type.serializable_hash,
        project: project.serializable_hash,
        token: token.serializable_hash,
        experience_levels: Award::EXPERIENCE_LEVELS,
        specialties: expected_specialities_list,
        types: { 'Blah' => transfer_type2.id },
        form_url: project_award_type_award_path(project, award_type, award),
        form_action: 'PATCH',
        url_on_success: project_award_types_path,
        csrf_token: 'some_csrf_token',
        project_for_header: project.decorate.header_props(account),
        mission_for_header: {
          name: mission.name, image_url: get_image_variant_path_context.path,
          url: mission_path(mission)
        }
      }
    end

    before do
      allow(project).to receive(:header_props).with(account).and_return(header_props)

      login(account)
      get :edit, params: { project_id: project.id, award_type_id: award_type.id, id: award.id }
    end

    it 'should respond with success' do
      expect(response.status).to eq 200
      expect(assigns[:props]).to eq expected_form_properties
      expect(response).to render_template(:edit)
    end
  end

  describe '#update' do
    let!(:award) { create(:award_ready) }

    before do
      login(award.project.account)
    end

    it 'updates task' do
      patch :update, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        id: award.to_param,
        task: {
          name: 'updated'
        }
      }
      expect(response.status).to eq(200)
      expect(response.media_type).to eq('application/json')

      expect(award.reload.name).to eq('updated')
      expect(award.reload.issuer).to eq award.project.account
    end

    it 'returns an error' do
      patch :update, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        id: award.to_param,
        task: {
          name: ''
        }
      }
      expect(response.status).to eq(422)
      expect(response.media_type).to eq('application/json')
    end
  end

  describe '#destroy' do
    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }

    let!(:award) do
      FactoryBot.create :award, account: account, award_type: award_type, status: 'invite_ready',
                                transfer_type: transfer_type, issuer: account
    end

    before { login account }

    context 'when award is valid' do
      before do
        delete :destroy, params: {
          project_id: project.id, award_type_id: award_type.id, id: award.id
        }
      end

      it 'cancels the task and redirects to project award types page' do
        expect(response).to redirect_to project_award_types_path(award.project)
        expect(flash[:notice]).to eq 'Task cancelled'
        expect(award.reload.status).to eq 'cancelled'
      end
    end

    context 'when award is not valid' do
      before do
        award.why = 'a' * 501
        award.save(validate: false)

        delete :destroy, params: {
          project_id: project.id, award_type_id: award_type.id, id: award.id
        }
      end

      it 'does not cancel the task and redirects to project award types page' do
        expect(response).to redirect_to project_award_types_path(award.project)
        expect(flash[:error]).to eq 'Why is too long (maximum is 500 characters)'
        expect(award.reload.status).to eq 'invite_ready'
      end
    end
  end

  describe '#award' do
    let(:account) { FactoryBot.create(:account, created_at: now) }
    let(:token) { FactoryBot.create(:token, created_at: now) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:mission) { FactoryBot.create(:mission, created_at: now) }
    let(:project) do
      FactoryBot.create :project, account: account, token: token, mission: mission, created_at: now
    end
    let(:award_type) { FactoryBot.create(:award_type, project: project, created_at: now) }
    let!(:transfer_type) do
      FactoryBot.create(:transfer_type, project: project, name: 'mint', created_at: now)
    end
    let(:award) do
      FactoryBot.create :award, account: account, award_type: award_type,
                                transfer_type: transfer_type, issuer: account, created_at: now
    end
    let!(:channel1) { FactoryBot.create(:channel, :slack, project: project) }
    let!(:channel2) { FactoryBot.create(:channel, :discord, project: project) }

    let(:expected_form_properties) do
      {
        task: award.serializable_hash,
        batch: award_type.serializable_hash,
        project: project.serializable_hash,
        token: token.serializable_hash,
        recipient_address_url:
          project_award_type_award_recipient_address_path(project, award_type, award),
        form_url: project_award_type_award_send_award_path(project, award_type, award),
        members: {
          channel1.id.to_s => { 'bob' => '234', 'jason' => '123' },
          channel2.id.to_s => { 'bob' => '234', 'jason' => '123' }
        },
        form_action: 'POST',
        url_on_success: project_award_types_path,
        channels: {
          'Email' => '',
          channel1.channel_id => channel1.id.to_s, channel2.channel_id => channel2.id.to_s
        },
        csrf_token: 'some_csrf_token',
        project_for_header: project.decorate.header_props(account),
        mission_for_header: {
          name: mission.name, image_url: get_image_variant_path_context.path,
          url: mission_path(mission)
        }
      }
    end

    before do
      allow(project).to receive(:header_props).with(account).and_return(header_props)
      allow_any_instance_of(Channel).to receive(:members).and_return([%w[jason 123], %w[bob 234]])

      login(account)
      get :award,
          params: { project_id: project.id, award_type_id: award_type.id, award_id: award.id }
    end

    it 'should respond with success' do
      expect(response.status).to eq 200
      expect(assigns[:props]).to eq expected_form_properties
      expect(response).to render_template(:award)
    end
  end

  describe '#start' do
    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project, state: :public) }

    before { login(account) }

    context 'when award cannot be cloned' do
      let!(:award) do
        FactoryBot.create :award, account: account, transfer_type: transfer_type,
                                  award_type: award_type, issuer: account, status: 'ready'
      end

      context 'when award is valid' do
        before do
          post :start, params: {
            project_id: project.id, award_type_id: award_type.id, award_id: award.id
          }
        end

        it 'starts the task, associating it with current user and redirects to task details page with notice' do
          expect(response).to redirect_to project_award_type_award_path(project, award_type, award)
          expect(flash[:notice]).to eq('Task started')
          expect(award.reload.status).to eq 'started'
        end
      end

      context 'when award is not valid' do
        before do
          award.why = 'a' * 501
          award.save(validate: false)

          post :start, params: {
            project_id: project.id, award_type_id: award_type.id, award_id: award.id
          }
        end

        it 'does not start the task and redirects to task list page with error' do
          expect(response).to redirect_to my_tasks_path(filter: 'ready')
          expect(flash[:error]).to eq 'Why is too long (maximum is 500 characters)'
          expect(award.reload.status).to eq 'ready'
        end
      end
    end

    context 'when award can be cloned' do
      let!(:award) do
        FactoryBot.create :award, account: account, transfer_type: transfer_type,
                                  award_type: award_type, issuer: account, number_of_assignments: 2,
                                  status: 'ready'
      end

      context 'when award is valid' do
        before do
          post :start, params: {
            project_id: project.id, award_type_id: award_type.id, award_id: award.id
          }
        end

        it 'clones the task before start if it should be cloned' do
          cloned_award = award.assignments.last

          expect(response)
            .to redirect_to project_award_type_award_path(project, award_type, cloned_award)
          expect(flash[:notice]).to eq('Task started')
          expect(award.reload.status).to eq 'ready'
          expect(cloned_award.status).to eq 'started'
        end
      end

      context 'when award is not valid' do
        before do
          award.why = 'a' * 501
          award.save(validate: false)
        end

        it 'raises error' do
          expect do
            post :start, params: {
              project_id: project.id, award_type_id: award_type.id, award_id: award.id
            }
          end.to raise_error
        end
      end
    end

    context 'when user is not authorized to start' do
      let!(:award) do
        FactoryBot.create :award, account: account, transfer_type: transfer_type,
                                  award_type: award_type, issuer: account, status: 'submitted',
                                  specialty: specialty, experience_level: 10
      end
      let!(:experience) do
        FactoryBot.create(:experience, account: account, specialty: specialty, level: 3)
      end

      before do
        post :start, params: {
          project_id: project.id, award_type_id: award_type.id, award_id: award.id
        }
      end

      context 'when award is of some specific specialty' do
        let(:specialty) { FactoryBot.create :specialty, name: 'Research' }

        it 'does not start the task and redirects to task list page with notice' do
          expect(response).to redirect_to my_tasks_path
          expect(flash[:notice]).to eq 'Complete 7 more Research tasks to access tasks that '\
                                       'require the Established Contributor skill level'
          expect(award.reload.status).to eq 'submitted'
        end
      end

      context 'when award is of the default specialty' do
        let(:specialty) { Specialty.default }

        it 'does not start the task and redirects to task list page with notice' do
          expect(response).to redirect_to my_tasks_path
          expect(flash[:notice]).to eq 'Complete 7 more tasks to access General tasks that '\
                                       'require the Established Contributor skill level'
          expect(award.reload.status).to eq 'submitted'
        end
      end
    end
  end

  describe '#assign' do
    let(:account) { FactoryBot.create(:account) }
    let(:target_account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project, state: 'public') }

    let(:mail) { double(:mail, deliver_now: nil) }
    let(:mail_task) { double(:mail_task, task_assigned: mail) }

    before do
      allow(TaskMailer).to receive(:with).and_return(mail_task)

      login account
    end

    shared_examples 'update award' do
      it do
        expect(award.reload)
          .to have_attributes account: target_account, issuer: account, status: 'ready'
      end
    end

    shared_examples 'not update award' do
      it do
        expect(award.reload)
          .to have_attributes account: account, issuer: account, status: 'invite_ready'
      end
    end

    shared_examples 'clone award' do
      it do
        expect(award.reload.assignments.last)
          .to have_attributes account: target_account, issuer: account, status: 'ready'
      end
    end

    shared_examples 'not clone award' do
      it do
        expect(award.reload.assignments.last).to eq nil
      end
    end

    shared_examples 'send task assigned email notification with original award' do
      it do
        expect(TaskMailer).to have_received(:with).with(award: award, whitelabel_mission: nil)
        expect(TaskMailer).to have_received(:with).once

        expect(mail_task).to have_received(:task_assigned).once
        expect(mail).to have_received(:deliver_now).once
      end
    end

    shared_examples 'send task assigned email notification with award clone' do
      it do
        expect(TaskMailer)
          .to have_received(:with)
          .with(award: award.reload.assignments.last, whitelabel_mission: nil)
        expect(TaskMailer).to have_received(:with).once

        expect(mail_task).to have_received(:task_assigned).once
        expect(mail).to have_received(:deliver_now).once
      end
    end

    shared_examples 'not send task assigned email notification' do
      it do
        expect(TaskMailer).not_to have_received(:with)
        expect(mail_task).not_to have_received(:task_assigned)
        expect(mail).not_to have_received(:deliver_now)
      end
    end

    shared_examples 'redirects to batches page with error' do |error_message|
      it do
        expect(response).to redirect_to project_award_types_path(project)
        expect(flash[:error]).to eq error_message
      end
    end

    shared_examples 'redirects to batches page with notice' do |notice_message|
      it do
        expect(response).to redirect_to project_award_types_path(project)
        expect(flash[:notice]).to eq notice_message
      end
    end

    context 'when award can be cloned' do
      context 'when award can be cloned for account' do
        let!(:award) do
          FactoryBot.create :award, account: account, award_type: award_type,
                                    status: 'invite_ready', transfer_type: transfer_type,
                                    issuer: account, number_of_assignments: 2
        end

        before do
          allow_any_instance_of(Award)
            .to receive(:can_be_cloned_for?).with(target_account).and_return(true)
        end

        context 'when award is valid' do
          before do
            post :assign, params: {
              project_id: project.id, award_type_id: award_type.id, award_id: award.id,
              account_id: target_account.id
            }
          end

          it_behaves_like 'not update award'
          it_behaves_like 'clone award'
          it_behaves_like 'send task assigned email notification with award clone'
          it_behaves_like 'redirects to batches page with notice', 'Task has been assigned'
        end

        context 'when award is not valid' do
          before do
            award.why = 'a' * 501
            award.save(validate: false)
          end

          it 'should raise error and not update award' do
            expect do
              post :assign, params: {
                project_id: project.id, award_type_id: award_type.id, award_id: award.id,
                account_id: target_account.id
              }
            end.to raise_error

            expect(award.reload)
              .to have_attributes account: account, issuer: account, status: 'invite_ready'
          end

          it 'should not clone award' do
            expect do
              post :assign, params: {
                project_id: project.id, award_type_id: award_type.id, award_id: award.id,
                account_id: target_account.id
              }
            end.to raise_error

            expect(award.reload.assignments.last).to eq nil
          end

          it 'should not send task submitted email notification' do
            expect do
              post :assign, params: {
                project_id: project.id, award_type_id: award_type.id, award_id: award.id,
                account_id: target_account.id
              }
            end.to raise_error

            expect(TaskMailer).not_to have_received(:with)
            expect(mail_task).not_to have_received(:task_assigned)
            expect(mail).not_to have_received(:deliver_now)
          end
        end
      end

      context 'when award cannot be cloned for account' do
        let!(:award) do
          FactoryBot.create :award, account: account, award_type: award_type,
                                    status: 'invite_ready', transfer_type: transfer_type,
                                    issuer: account, number_of_assignments: 2
        end

        before do
          allow_any_instance_of(Award)
            .to receive(:can_be_cloned_for?).with(target_account).and_return(false)
        end

        context 'when award is valid' do
          before do
            post :assign, params: {
              project_id: project.id, award_type_id: award_type.id, award_id: award.id,
              account_id: target_account.id
            }
          end

          it_behaves_like 'update award'
          it_behaves_like 'not clone award'
          it_behaves_like 'send task assigned email notification with original award'
          it_behaves_like 'redirects to batches page with notice', 'Task has been assigned'
        end

        context 'when award is not valid' do
          before do
            award.why = 'a' * 501
            award.save(validate: false)

            post :assign, params: {
              project_id: project.id, award_type_id: award_type.id, award_id: award.id,
              account_id: target_account.id
            }
          end

          it_behaves_like 'not update award'
          it_behaves_like 'not clone award'
          it_behaves_like 'not send task assigned email notification'
          it_behaves_like 'redirects to batches page with error',
                          'Why is too long (maximum is 500 characters)'
        end
      end
    end

    context 'when award cannot be cloned' do
      let!(:award) do
        FactoryBot.create :award, account: account, award_type: award_type, status: 'invite_ready',
                                  transfer_type: transfer_type, issuer: account
      end

      context 'when award is valid' do
        before do
          post :assign, params: {
            project_id: project.id, award_type_id: award_type.id, award_id: award.id,
            account_id: target_account.id
          }
        end

        it_behaves_like 'update award'
        it_behaves_like 'not clone award'
        it_behaves_like 'send task assigned email notification with original award'
        it_behaves_like 'redirects to batches page with notice', 'Task has been assigned'
      end

      context 'when award is not valid' do
        before do
          award.why = 'a' * 501
          award.save(validate: false)

          post :assign, params: {
            project_id: project.id, award_type_id: award_type.id, award_id: award.id,
            account_id: target_account.id
          }
        end

        it_behaves_like 'not update award'
        it_behaves_like 'not clone award'
        it_behaves_like 'not send task assigned email notification'
        it_behaves_like 'redirects to batches page with error',
                        'Why is too long (maximum is 500 characters)'
      end
    end
  end

  describe '#assignment' do
    let!(:account) { FactoryBot.create(:account, created_at: now) }

    let(:role1) { FactoryBot.create(:account, created_at: now) }
    let!(:role1_project_role) do
      FactoryBot.create(:project_role, project: project, account: role1)
    end

    let(:role2) { FactoryBot.create(:account, created_at: now) }
    let!(:role2_project_role) do
      FactoryBot.create(:project_role, project: project, account: role2)
    end

    let!(:other_account) { FactoryBot.create(:account, created_at: now) }

    let(:contributor) { FactoryBot.create(:account, created_at: now) }
    let!(:contributor_award) do
      FactoryBot.create :award, account: contributor, award_type: award_type,
                                transfer_type: transfer_type, issuer: account, created_at: now
    end

    let(:token) { FactoryBot.create(:token, created_at: now) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:mission) { FactoryBot.create(:mission, created_at: now) }
    let(:project) do
      FactoryBot.create :project, account: account, token: token, mission: mission, created_at: now,
                                  visibility: :public_listed
    end
    let(:award_type) { FactoryBot.create(:award_type, project: project, created_at: now) }
    let!(:transfer_type) do
      FactoryBot.create(:transfer_type, project: project, name: 'mint', created_at: now)
    end
    let(:award) do
      FactoryBot.create :award, account: account, award_type: award_type,
                                transfer_type: transfer_type, issuer: account, created_at: now
    end
    let(:base_account_data) do
      {
        'behance_url' => nil, 'dribble_url' => nil, 'github_url' => nil,
        'image_url' => 'some_image_path', 'linkedin_url' => nil, 'nickname' => nil
      }
    end

    let(:expected_form_properties) do
      {
        task: { id: award.id, name: award.name }.as_json,
        batch: { id: award_type.id, name: award_type.name }.as_json,
        project: {
          id: project.id, title: project.title, public?: true,
          url: unlisted_project_url(project.long_id)
        }.as_json,
        accounts: [
          base_account_data.merge(account.attributes.slice('id', 'first_name', 'last_name')),
          base_account_data.merge(role1.attributes.slice('id', 'first_name', 'last_name')),
          base_account_data.merge(role2.attributes.slice('id', 'first_name', 'last_name')),
          base_account_data.merge(contributor.attributes.slice('id', 'first_name', 'last_name'))
        ],
        accounts_select: {
          '' => nil, account.name => account.id, role1.name => role1.id, role2.name => role2.id,
          contributor.name => contributor.id
        },
        form_url: project_award_type_award_assign_path(project, award_type, award),
        csrf_token: 'some_csrf_token',
        project_for_header: project.decorate.header_props(account),
        mission_for_header: {
          name: mission.name, image_url: get_image_variant_path_context.path,
          url: mission_path(mission)
        }
      }
    end

    before do
      allow(project).to receive(:header_props).with(account).and_return(header_props)

      login(account)
      get :assignment,
          params: { project_id: project.id, award_type_id: award_type.id, award_id: award.id }
    end

    it 'should respond with success' do
      expect(response.status).to eq 200
      expect(assigns[:props]).to eq expected_form_properties
      expect(response).to render_template(:assignment)
    end
  end

  describe '#submit' do
    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }

    let!(:award) do
      FactoryBot.create :award, account: account, award_type: award_type, status: 'started',
                                transfer_type: transfer_type, issuer: account
    end

    let(:mail) { double(:mail, deliver_now: nil) }
    let(:mail_task) { double(:mail_task, task_submitted: mail) }

    before do
      allow(TaskMailer).to receive(:with).and_return(mail_task)

      login account
    end

    context 'without submission params' do
      before do
        post :submit, params: {
          project_id: award.project.id, award_type_id: award.award_type.id, award_id: award.id
        }
      end

      it 'does not submit the task and redirects to task details with error' do
        expect(response).to redirect_to project_award_type_award_path(project, award_type, award)
        expect(flash[:error]).to eq 'You must submit a comment, image or URL documenting your work.'
        expect(award.reload.status).to eq 'started'
      end

      it 'should not send task submitted email notification' do
        expect(TaskMailer).not_to have_received(:with)
        expect(mail_task).not_to have_received(:task_submitted)
        expect(mail).not_to have_received(:deliver_now)
      end
    end

    context 'with submission params' do
      before do
        post :submit, params: {
          project_id: project.id, award_type_id: award_type.id, award_id: award.id,
          task: { submission_url: 'http://test', submission_comment: 'test' }
        }
      end

      it 'submits the task and redirects to user submitted tasks page with notice' do
        expect(response).to redirect_to my_tasks_path(filter: 'submitted')
        expect(flash[:notice]).to eq('Task submitted')
        expect(award.reload.status).to eq 'submitted'
      end

      it 'should send task submitted email notification' do
        expect(TaskMailer).to have_received(:with).with(award: award, whitelabel_mission: nil)
        expect(TaskMailer).to have_received(:with).once

        expect(mail_task).to have_received(:task_submitted).once
        expect(mail).to have_received(:deliver_now).once
      end
    end

    context 'when award is invalid' do
      before do
        award.why = 'a' * 501
        award.save(validate: false)

        post :submit, params: {
          project_id: project.id, award_type_id: award_type.id, award_id: award.id,
          task: { submission_url: 'http://test', submission_comment: 'test' }
        }
      end

      it 'does not submit the task and redirects to task details with error' do
        expect(response).to redirect_to project_award_type_award_path(project, award_type, award)
        expect(flash[:error]).to eq 'Why is too long (maximum is 500 characters)'
        expect(award.reload.status).to eq 'started'
      end

      it 'should not send task submitted email notification' do
        expect(TaskMailer).not_to have_received(:with)
        expect(mail_task).not_to have_received(:task_submitted)
        expect(mail).not_to have_received(:deliver_now)
      end
    end
  end

  describe '#accept' do
    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }

    let!(:award) do
      FactoryBot.create :award, account: account, status: 'submitted', award_type: award_type,
                                transfer_type: transfer_type, issuer: account
    end

    let(:mail) { double(:mail, deliver_now: nil) }
    let(:mail_task) { double(:mail_task, task_accepted: mail) }

    before do
      allow(TaskMailer).to receive(:with).and_return(mail_task)

      login account
    end

    context 'when award is valid' do
      before do
        post :accept, params: {
          project_id: project.id, award_type_id: award_type.id, award_id: award.id
        }
      end

      it 'accepts the task and redirects to my task page with notice' do
        expect(response).to redirect_to(my_tasks_path(filter: 'to pay'))
        expect(flash[:notice]).to eq('Task accepted')
        expect(award.reload.status).to eq 'accepted'
      end

      it 'should send task accepted email notification' do
        expect(TaskMailer).to have_received(:with).with(award: award, whitelabel_mission: nil)
        expect(TaskMailer).to have_received(:with).once

        expect(mail_task).to have_received(:task_accepted).once
        expect(mail).to have_received(:deliver_now).once
      end
    end

    context 'when award is not valid' do
      before do
        award.why = 'a' * 501
        award.save(validate: false)

        post :accept, params: {
          project_id: project.id, award_type_id: award_type.id, award_id: award.id
        }
      end

      it 'does not accept the task and redirects to task for review list page with error' do
        expect(response).to redirect_to my_tasks_path(filter: 'to review')
        expect(flash[:error]).to eq 'Why is too long (maximum is 500 characters)'
        expect(award.reload.status).to eq 'submitted'
      end

      it 'should not send task accepted email notification' do
        expect(TaskMailer).not_to have_received(:with)
        expect(mail_task).not_to have_received(:task_accepted)
        expect(mail).not_to have_received(:deliver_now)
      end
    end
  end

  describe '#reject' do
    let(:account) { FactoryBot.create(:account) }
    let(:token) { FactoryBot.create(:token) }
    let(:project) { FactoryBot.create :project, account: account, token: token }
    let!(:transfer_type) { FactoryBot.create(:transfer_type, project: project) }
    let(:wallet) { FactoryBot.create(:wallet, account: account, _blockchain: token._blockchain) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }

    let!(:award) do
      FactoryBot.create :award, account: account, status: 'submitted', award_type: award_type,
                                transfer_type: transfer_type, issuer: account
    end

    let(:mail) { double(:mail, deliver_now: nil) }
    let(:mail_task) { double(:mail_task, task_rejected: mail) }

    before do
      allow(TaskMailer).to receive(:with).and_return(mail_task)

      login account
    end

    context 'when award is valid' do
      before do
        post :reject, params: {
          project_id: project.id, award_type_id: award_type.id, award_id: award.id
        }
      end

      it 'rejects the task and redirects to my task page with notice' do
        expect(response).to redirect_to(my_tasks_path(filter: 'done'))
        expect(flash[:notice]).to eq('Task rejected')
        expect(award.reload.status).to eq 'rejected'
      end

      it 'should send task rejected email notification' do
        expect(TaskMailer).to have_received(:with).with(award: award, whitelabel_mission: nil)
        expect(TaskMailer).to have_received(:with).once

        expect(mail_task).to have_received(:task_rejected).once
        expect(mail).to have_received(:deliver_now).once
      end
    end

    context 'when award is not valid' do
      before do
        award.why = 'a' * 501
        award.save(validate: false)

        post :reject, params: {
          project_id: project.id, award_type_id: award_type.id, award_id: award.id
        }
      end

      it 'does not reject the task and redirects to task for review list page with error' do
        expect(response).to redirect_to my_tasks_path(filter: 'to review')
        expect(flash[:error]).to eq 'Why is too long (maximum is 500 characters)'
        expect(award.reload.status).to eq 'submitted'
      end

      it 'should not send task rejected email notification' do
        expect(TaskMailer).not_to have_received(:with)
        expect(mail_task).not_to have_received(:task_rejected)
        expect(mail).not_to have_received(:deliver_now)
      end
    end
  end

  describe '#send_award' do
    let(:account) { FactoryBot.create(:account) }
    let(:award_type) { FactoryBot.create(:award_type, project: project) }
    let!(:transfer_type) do
      FactoryBot.create(:transfer_type, project: project, name: 'mint')
    end
    let(:award) do
      FactoryBot.create :award, award_type: award_type, amount: 100, quantity: 1, issuer: account,
                                account: nil, status: 'ready', transfer_type: transfer_type
    end
    let(:award2) do
      FactoryBot.create :award, award_type: award_type, amount: 100, quantity: 1, issuer: account,
                                account: nil, status: 'ready', transfer_type: transfer_type
    end
    let!(:channel) { FactoryBot.create :channel, :slack, project: project, channel_id: '123' }

    before { allow_any_instance_of(Award).to receive(:send_award_notifications) }

    context 'when logged in' do
      before do
        login(issuer.account)
        request.env['HTTP_REFERER'] = "/projects/#{project.to_param}"
      end

      context 'when slack channel' do
        before do
          post :send_award, params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            award_id: award.to_param,
            task: {
              uid: receiver.uid,
              quantity: 1.5,
              channel_id: channel.id,
              message: 'Great work'
            }
          }
        end

        it 'records a slack award being created' do
          expect(response.status).to eq(200)

          expect(award.reload.award_type).to eq award_type
          expect(award.account).to eq receiver.account
          expect(award.quantity).to eq 1.5

          recipient_name = award.decorate.recipient_display_name.possessive
          expect(flash[:notice]).to eq "#{recipient_name} task has been accepted. "\
                                       'Initiate payment for the task on the payments page.'
        end
      end

      context 'when discord channel' do
        let!(:channel) { FactoryBot.create :channel, :discord, project: project, channel_id: '123' }

        before do
          stub_discord_channels

          post :send_award, params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            award_id: award2.to_param,
            task: {
              uid: receiver_discord.uid,
              quantity: 1.5,
              channel_id: channel.id,
              message: 'Great work'
            }
          }
        end

        it 'records a discord award being created' do
          expect(response.status).to eq(200)

          expect(award2.reload.discord?).to eq true
          expect(award2.award_type).to eq award_type
          expect(award2.account).to eq receiver.account
          expect(award2.quantity).to eq 1.5

          recipient_name = award2.decorate.recipient_display_name.possessive
          expect(flash[:notice]).to eq "#{recipient_name} task has been accepted. "\
                                       'Initiate payment for the task on the payments page.'
        end
      end

      context 'when wallet blockchain does not match token blockchain' do
        let!(:wallet) do
          FactoryBot.create :wallet, account: receiver.account, _blockchain: :ethereum_kovan,
                                     address: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367',
                                     primary_wallet: false
        end
        let(:award) do
          FactoryBot.create :award, award_type: award_type, amount: 100, quantity: 1,
                                    issuer: account, account: nil, status: 'ready',
                                    transfer_type: transfer_type
        end

        before do
          post :send_award, params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            award_id: award.to_param,
            task: {
              uid: receiver.uid,
              quantity: 1.5,
              channel_id: channel.id,
              message: 'Great work'
            }
          }
        end

        it 'records a slack award being created' do
          expect(response.status).to eq(200)

          expect(award.reload.award_type).to eq award_type
          expect(award.account).to eq receiver.account
          expect(award.quantity).to eq 1.5

          expect(flash[:notice])
            .to eq "The award recipient hasn't entered a blockchain address for us to send the "\
                   'award to. When the recipient enters their blockchain address you will be '\
                   'able to approve the token transfer on the awards page.'
        end
      end

      context 'when award sending fails' do
        before do
          award.why = 'a' * 501
          award.save(validate: false)

          post :send_award, params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            award_id: award.to_param,
            task: {
              uid: receiver.uid,
              quantity: 1.5,
              channel_id: channel.id,
              message: 'Great work'
            }
          }
        end

        it 'should respond with unprocessable entity status' do
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body))
            .to eq 'id' => award.id,
                   'errors' => { 'task[why]' => 'is too long (maximum is 500 characters)' },
                   'message' => 'Why is too long (maximum is 500 characters)'
        end
      end
    end

    context 'when logged in not as project owner' do
      before do
        account = create(:account)
        login(account)
        request.env['HTTP_REFERER'] = "/projects/#{project.to_param}"
      end

      it 'can not send the award' do
        award.update(account: nil, status: 'ready')

        post :send_award, params: {
          project_id: project.to_param,
          award_type_id: award_type.to_param,
          award_id: award.to_param,
          task: {
            email: 'test@example.com',
            quantity: 1.5,
            message: 'Great work'
          }
        }

        expect(response.status).to eq(302)
      end
    end
  end

  describe '#confirm' do
    let!(:award) { create(:award, award_type: create(:award_type, project: project), issuer: issuer.account, account: nil, email: 'receiver@test.st', confirm_token: '1234') }

    it 'redirect_to login page' do
      get :confirm, params: { token: 1234 }
      expect(response).to redirect_to(new_account_path)
      expect(session[:redeem]).to eq true
    end

    it 'redirect_to show error for invalid token' do
      login receiver.account
      get :confirm, params: { token: 12_345 }
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq 'Invalid award token!'
    end

    it 'add award to account' do
      login receiver.account
      get :confirm, params: { token: 1234 }
      expect(response).to redirect_to(project_path(award.project))
      expect(award.reload.account_id).to eq receiver.account_id
      expect(flash[:notice].include?('Congratulations, you just claimed your award!')).to be_truthy
    end

    it 'add award to account. notice about update wallet address' do
      account = receiver.account
      account.wallets.delete_all
      login receiver.account
      get :confirm, params: { token: 1234 }
      expect(response).to redirect_to(project_path(award.project))
      expect(award.reload.account_id).to eq receiver.account_id
      expect(flash[:notice].include?('Congratulations, you just claimed your award! Be sure to enter your')).to be_truthy
    end
  end

  describe '#update_transaction_address' do
    let(:transaction_address) { '0xdb6f4aad1b0de83284855aafafc1b0a4961f4864b8a627b5e2009f5a6b2346cd' }
    let(:award_type) { create(:award_type, project: project) }
    let!(:award) { create(:award, status: :accepted, award_type: award_type, issuer: issuer.account, confirm_token: '1234') }

    it 'handles tx address' do
      login issuer.account
      post :update_transaction_address, format: 'js', params: {
        project_id: project.to_param,
        award_type_id: award_type.to_param,
        award_id: award.id,
        tx: transaction_address
      }
      award.reload
      expect(award.ethereum_transaction_address).to eq transaction_address
      expect(award.issuer).to eq issuer.account
      expect(award.status).to eq 'paid'
    end

    it 'handles tx receipt' do
      login issuer.account
      post :update_transaction_address, format: 'js', params: {
        project_id: project.to_param,
        award_type_id: award_type.to_param,
        award_id: award.id,
        receipt: '{"status": true}'
      }
      award.reload
      expect(award.transaction_success).to be_truthy
    end

    it 'handles tx error' do
      login issuer.account
      post :update_transaction_address, format: 'js', params: {
        project_id: project.to_param,
        award_type_id: award_type.to_param,
        award_id: award.id,
        error: 'test error'
      }
      award.reload
      expect(award.transaction_error).to eq 'test error'
    end

    it 'fails' do
      post :update_transaction_address, format: 'js', params: {
        project_id: project.to_param,
        award_type_id: award_type.to_param,
        award_id: award.id,
        tx: transaction_address
      }
      expect(award.reload.ethereum_transaction_address).to be_nil
    end
  end

  describe '#recipient_address' do
    let(:token) do
      FactoryBot.create :token, _token_type: 'erc20', _blockchain: :ethereum_ropsten,
                                contract_address: '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37'
    end
    let(:account) { FactoryBot.create(:account, email: 'bobjohnson@example.com') }
    let(:project) do
      FactoryBot.create :project, account: account, public: false,
                                  maximum_tokens: 100_000_000, token: token
    end
    let(:award_type) { FactoryBot.create(:award_type, project: project) }
    let!(:transfer_type) do
      FactoryBot.create(:transfer_type, project: project, name: 'mint')
    end
    let(:award) do
      FactoryBot.create :award, award_type: award_type, transfer_type: transfer_type,
                                issuer: account
    end
    let!(:wallet) do
      FactoryBot.create :wallet, account: account, _blockchain: :ethereum_ropsten,
                                 address: '0xaBe4449277c893B3e881c29B17FC737ff527Fa47'
    end
    let!(:channel) { FactoryBot.create :channel, project: project, channel_id: '123' }

    before { login account }

    context 'with email' do
      let!(:account) { FactoryBot.create(:account, email: 'test2@comakery.com') }
      let!(:wallet) do
        FactoryBot.create :wallet, account: account, _blockchain: :ethereum_ropsten,
                                   address: '0xaBe4449277c893B3e881c29B17FC737ff527Fa47'
      end
      let!(:wallet2) do
        FactoryBot.create :wallet, account: account, address: 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM',
                                   _blockchain: :qtum
      end

      before { award.update(status: 'ready') }

      context 'with erc20 token' do
        before do
          post :recipient_address, format: 'js', params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            award_id: award.id,
            email: 'test2@comakery.com'
          }
        end

        it 'should respond with success' do
          expect(response.status).to eq(200)
          expect(response.media_type).to eq('application/json')
          expect(JSON.parse(response.body))
            .to eq 'address' => '0xaBe4449277c893B3e881c29B17FC737ff527Fa47',
                   'walletUrl' => 'https://ropsten.etherscan.io/address/'\
                                  '0xaBe4449277c893B3e881c29B17FC737ff527Fa47'
        end
      end

      context 'with qrc20 token' do
        let!(:token) do
          FactoryBot.create :token, _token_type: 'qrc20',
                                    contract_address: '0x1D1592c28FFF3d3E71b1d29E31147846026A0a37',
                                    _blockchain: :qtum
        end

        before do
          award.update(status: 'ready')

          post :recipient_address, format: 'js', params: {
            project_id: project.to_param,
            award_type_id: award_type.to_param,
            award_id: award.to_param,
            email: 'test2@comakery.com'
          }
        end

        it 'should respond with success' do
          expect(response.status).to eq(200)
          expect(response.media_type).to eq('application/json')
          expect(JSON.parse(response.body))
            .to eq 'address' => 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM',
                   'walletUrl' =>
                     'https://explorer.qtum.org/address/qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM'
        end
      end
    end

    context 'with channel_id and uid' do
      let!(:account) { FactoryBot.create(:account, email: 'bobjohnson@example.com') }
      let!(:project) { FactoryBot.create :project, account: account, token: token }
      let!(:wallet) do
        FactoryBot.create :wallet, account: account, _blockchain: :ethereum_ropsten,
                                   address: '0xaBe4449277c893B3e881c29B17FC737ff527Fa48'
      end
      let!(:team) { FactoryBot.create :team, :slack }
      let!(:channel) { FactoryBot.create :channel, project: project, team: team, channel_id: '123' }
      let!(:authentication) { FactoryBot.create :authentication, :slack, account: account }
      let!(:authentication_team) do
        FactoryBot.create :authentication_team, account: account, team: team,
                                                authentication: authentication
      end

      before do
        stub_request(:post, 'https://slack.com/api/users.info').to_return(body: {
          ok: true,
          "user": {
            "id": 'U99M9QYFQ',
            "team_id": 'team id',
            "name": 'bobjohnson',
            "profile": {
              email: 'bobjohnson@example.com'
            }
          }
        }.to_json)

        post :recipient_address, format: 'js', params: {
          project_id: project.to_param,
          award_type_id: award_type.to_param,
          award_id: award.to_param,
          uid: 'receiver id',
          channel_id: channel.id
        }
      end

      it 'should respond with success' do
        expect(response.status).to eq(200)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body))
          .to eq 'address' => '0xaBe4449277c893B3e881c29B17FC737ff527Fa48',
                 'walletUrl' =>
                   'https://ropsten.etherscan.io/address/0xaBe4449277c893B3e881c29B17FC737ff527Fa48'
      end
    end

    context 'when token is not assigned' do
      let!(:token) { nil }
      let!(:account) { FactoryBot.create(:account, email: 'bobjohnson@example.com') }
      let!(:wallet) do
        FactoryBot.create :wallet, account: account, _blockchain: :ethereum_ropsten,
                                   address: '0xaBe4449277c893B3e881c29B17FC737ff527Fa48'
      end

      before do
        award.update(status: 'ready')

        post :recipient_address, format: 'js', params: {
          project_id: project.to_param,
          award_type_id: award_type.to_param,
          award_id: award.to_param,
          email: 'test2@comakery.com'
        }
      end

      it 'should respond with success' do
        expect(response.status).to eq(200)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)).to eq 'address' => nil, 'walletUrl' => nil
      end
    end
  end
end
