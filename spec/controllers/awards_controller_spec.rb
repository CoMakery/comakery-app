require 'rails_helper'

RSpec.describe AwardsController, type: :controller do
  let!(:team) { create :team }
  let!(:discord_team) { create :team, provider: 'discord' }
  let!(:issuer) { create(:authentication) }
  let!(:issuer_discord) { create(:authentication, account: issuer.account, provider: 'discord') }
  let!(:receiver) { create(:authentication, account: create(:account, ethereum_wallet: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367')) }
  let!(:receiver_discord) { create(:authentication, account: receiver.account, provider: 'discord') }
  let!(:other_auth) { create(:authentication) }
  let!(:different_team_account) { create(:authentication) }

  let!(:project) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'erc20')) }
  let!(:award_type) { create(:award_type, project: project) }

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
      expect(response).to redirect_to(new_session_url)
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
    let(:award) { create(:award) }
    let(:project) do
      pj = award.project
      pj.public_listed!
      pj
    end

    let(:account) { project.account.decorate }

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
        expect do
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
    let!(:award) { create(:award, status: :accepted) }

    it 'sets task status to cancelled and redirects to batches page' do
      login(award.project.account)

      delete :destroy, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        id: award.to_param
      }

      expect(response).to redirect_to(project_award_types_path(award.project))
      expect(flash[:notice]).to eq('Task cancelled')
      expect(award.reload.cancelled?).to be true
    end
  end

  describe '#start' do
    let!(:award) { create(:award_ready) }
    let!(:award_cloneable) { create(:award_ready, number_of_assignments: 2) }

    it 'starts the task, associating it with current user and redirects to task details page with notice' do
      login(award.project.account)

      post :start, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        award_id: award.to_param
      }

      expect(response).to redirect_to(project_award_type_award_path(award.project, award.award_type, award))
      expect(flash[:notice]).to eq('Task started')
      expect(award.reload.started?).to be true
    end

    it 'clones the task before start if it should be cloned' do
      login(award_cloneable.project.account)
      post :start, params: {
        project_id: award_cloneable.project.to_param,
        award_type_id: award_cloneable.award_type.to_param,
        award_id: award_cloneable.to_param
      }

      cloned_award = Award.find_by(cloned_on_assignment_from_id: award_cloneable.id)

      expect(response).to redirect_to(project_award_type_award_path(cloned_award.project, cloned_award.award_type, cloned_award))
      expect(flash[:notice]).to eq('Task started')
      expect(award_cloneable.reload.ready?).to be true
      expect(cloned_award.started?).to be true
    end
  end

  describe '#assign' do
    let!(:award) { create(:award_ready) }
    let!(:award_cloneable) { create(:award_ready, number_of_assignments: 2) }
    let!(:account) { create(:account) }

    it 'assignes task with selected account and redirects to batches page with notice' do
      login(award.project.account)
      post :assign, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        award_id: award.to_param,
        account_id: account.id
      }

      expect(response).to redirect_to(project_award_types_path(award.project))
      expect(flash[:notice]).to eq('Task has been assigned')
      expect(award.reload.ready?).to be true
      expect(award.reload.account).to eq account
      expect(award.reload.issuer).to eq award.project.account
    end

    it 'clones the task before assignement if it should be cloned' do
      login(award_cloneable.project.account)
      post :assign, params: {
        project_id: award_cloneable.project.to_param,
        award_type_id: award_cloneable.award_type.to_param,
        award_id: award_cloneable.to_param,
        account_id: account.id
      }

      cloned_award = Award.find_by(cloned_on_assignment_from_id: award_cloneable.id)

      expect(response).to redirect_to(project_award_types_path(award_cloneable.project))
      expect(flash[:notice]).to eq('Task has been assigned')
      expect(award_cloneable.reload.ready?).to be true
      expect(cloned_award.reload.ready?).to be true
      expect(cloned_award.reload.account).to eq account
      expect(cloned_award.reload.issuer).to eq award_cloneable.project.account
    end
  end

  describe '#submit' do
    let!(:award) { create(:award) }

    before do
      login(award.account)
      award.update(status: 'started')
    end

    it 'submits the task and redirects to my task page with notice' do
      post :submit, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        award_id: award.to_param,
        task: {
          submission_url: 'http://test',
          submission_comment: 'test'
        }
      }
      expect(response).to redirect_to(my_tasks_path(filter: 'submitted'))
      expect(flash[:notice]).to eq('Task submitted')
      expect(award.reload.submitted?).to be true
    end

    it 'redirects back task details with an error' do
      post :submit, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        award_id: award.to_param,
        task: {

        }
      }
      expect(response).to redirect_to(project_award_type_award_path(award.project, award.award_type, award))
      expect(flash[:error]).to eq('You must submit a comment, image or URL documenting your work.')
      expect(award.reload.submitted?).to be false
    end
  end

  describe '#accept' do
    let!(:award) { create(:award) }

    before do
      login(award.project.account)
      award.update(status: 'submitted')
    end

    it 'accepts the task and redirects to my task page with notice' do
      post :accept, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        award_id: award.to_param
      }
      expect(response).to redirect_to(my_tasks_path(filter: 'to pay'))
      expect(flash[:notice]).to eq('Task accepted')
      expect(award.reload.accepted?).to be true
    end
  end

  describe '#reject' do
    let!(:award) { create(:award) }

    before do
      login(award.project.account)
      award.update(status: 'submitted')
    end

    it 'rejects the task and redirects to my task page with notice' do
      post :reject, params: {
        project_id: award.project.to_param,
        award_type_id: award.award_type.to_param,
        award_id: award.to_param
      }
      expect(response).to redirect_to(my_tasks_path(filter: 'done'))
      expect(flash[:notice]).to eq('Task rejected')
      expect(award.reload.rejected?).to be true
    end
  end

  describe '#send_award' do
    let(:award_type) { create(:award_type, project: project) }
    let(:award) do
      create(
        :award,
        award_type: award_type,
        amount: 100,
        quantity: 1,
        issuer: issuer.account
      )
    end
    let(:award2) do
      create(
        :award,
        award_type: award_type,
        amount: 100,
        quantity: 1,
        issuer: issuer.account
      )
    end

    before do
      login(issuer.account)
      request.env['HTTP_REFERER'] = "/projects/#{project.to_param}"
    end

    context 'logged in' do
      it 'records a slack award being created' do
        expect_any_instance_of(Award).to receive(:send_award_notifications)
        allow_any_instance_of(Award).to receive(:ethereum_issue_ready?) { true }

        award.update(account: nil, status: 'ready')

        post :send_award, params: {
          project_id: project.to_param,
          award_type_id: award_type.to_param,
          award_id: award.to_param,
          task: {
            uid: receiver.uid,
            quantity: 1.5,
            channel_id: project.channels.first.id,
            message: 'Great work'
          }
        }
        expect(response.status).to eq(200)

        award.reload

        expect(flash[:notice]).to eq("#{award.decorate.recipient_display_name.possessive} task has been accepted. Initiate payment for the task on the payments page.")
        expect(award.award_type).to eq(award_type)
        expect(award.account).to eq(receiver.account)
        expect(award.quantity).to eq(1.5)
      end

      it 'records a discord award being created' do
        expect_any_instance_of(Award).to receive(:send_award_notifications)
        allow_any_instance_of(Account).to receive(:ethereum_issue_ready?) { true }

        stub_discord_channels
        channel = project.channels.create(team: discord_team, channel_id: 'channel_id', name: 'discord_channel')

        award2.update(account: nil, status: 'ready')

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
        expect(response.status).to eq(200)

        award2.reload
        expect(flash[:notice]).to eq("#{award2.decorate.recipient_display_name.possessive} task has been accepted. Initiate payment for the task on the payments page.")
        expect(award2.discord?).to be_truthy
        expect(award2.award_type).to eq(award_type)
        expect(award2.account).to eq(receiver.account)
        expect(award2.quantity).to eq(1.5)
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
      get :confirm, params: { token: 12345 }
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
      account.update ethereum_wallet: nil
      login receiver.account
      get :confirm, params: { token: 1234 }
      expect(response).to redirect_to(project_path(award.project))
      expect(award.reload.account_id).to eq receiver.account_id
      expect(flash[:notice].include?('Congratulations, you just claimed your award! Be sure to enter your Ethereum Adress')).to be_truthy
    end

    context 'on Qtum network' do
      let(:project2) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'qrc20')) }
      let!(:award2) { create(:award, award_type: create(:award_type, project: project2), issuer: issuer.account, account: nil, email: 'receiver@test.st', confirm_token: '61234') }

      it 'add award to account' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, qtum_wallet: 'q' + 'a' * 33
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id
        expect(flash[:notice].include?('Congratulations, you just claimed your award! Your Qtum address is')).to be_truthy
      end

      it 'add award to account. notice about update qtum wallet address' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, qtum_wallet: nil
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id
        expect(flash[:notice].include?('Congratulations, you just claimed your award! Be sure to enter your Qtum Adress')).to be_truthy
      end
    end

    context 'on Cardano network' do
      let(:project2) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'ada')) }
      let!(:award2) { create(:award, award_type: create(:award_type, project: project2), issuer: issuer.account, account: nil, email: 'receiver@test.st', confirm_token: '61234') }

      it 'add award to account' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, cardano_wallet: 'Ae2tdPwUPEZ3uaf7wJVf7ces9aPrc6Cjiz5eG3gbbBeY3rBvUjyfKwEaswp'
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id

        expect(flash[:notice].include?('Congratulations, you just claimed your award! Your Cardano address is')).to be_truthy
      end

      it 'add award to account. notice about update Cardano wallet address' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, cardano_wallet: nil
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id
        expect(flash[:notice].include?('Congratulations, you just claimed your award! Be sure to enter your Cardano Adress')).to be_truthy
      end
    end

    context 'on Bitcoin network' do
      let(:project2) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'btc')) }
      let!(:award2) { create(:award, award_type: create(:award_type, project: project2), issuer: issuer.account, account: nil, email: 'receiver@test.st', confirm_token: '61234') }

      it 'add award to account' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, bitcoin_wallet: 'msb86hf6ssyYkAJ8xqKUjmBEkbW3cWCdps'
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id

        expect(flash[:notice].include?('Congratulations, you just claimed your award! Your Bitcoin address is')).to be_truthy
      end

      it 'add award to account. notice about update Bitcoin wallet address' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, bitcoin_wallet: nil
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id
        expect(flash[:notice].include?('Congratulations, you just claimed your award! Be sure to enter your Bitcoin Adress')).to be_truthy
      end
    end

    context 'on EOS network' do
      let(:project2) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'eos')) }
      let!(:award2) { create(:award, award_type: create(:award_type, project: project2), issuer: issuer.account, account: nil, email: 'receiver@test.st', confirm_token: '61234') }

      it 'add award to account' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, eos_wallet: 'aaatestnet11'
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id

        expect(flash[:notice].include?('Congratulations, you just claimed your award! Your EOS account name is')).to be_truthy
      end

      it 'add award to account. notice about update EOS wallet address' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, eos_wallet: nil
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id
        expect(flash[:notice].include?('Congratulations, you just claimed your award! Be sure to enter your EOS Adress')).to be_truthy
      end
    end

    context 'on Tezos network' do
      let(:project2) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'xtz')) }
      let!(:award2) { create(:award, award_type: create(:award_type, project: project2), issuer: issuer.account, account: nil, email: 'receiver@test.st', confirm_token: '61234') }

      it 'add award to account' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, tezos_wallet: 'tz1Zbe9hjjSnJN2U51E5W5fyRDqPCqWMCFN9'
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id

        expect(flash[:notice].include?('Congratulations, you just claimed your award! Your Tezos address is')).to be_truthy
      end

      it 'add award to account. notice about update Tezos wallet address' do
        account = receiver.account
        account.update ethereum_wallet: '0x' + 'a' * 40, tezos_wallet: nil
        login receiver.account
        get :confirm, params: { token: 61234 }
        expect(response).to redirect_to(project_path(award2.project))
        expect(award2.reload.account_id).to eq receiver.account_id
        expect(flash[:notice].include?('Congratulations, you just claimed your award! Be sure to enter your Tezos Adress')).to be_truthy
      end
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
      expect(award.ethereum_transaction_success).to be_truthy
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
      expect(award.ethereum_transaction_error).to eq 'test error'
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
    let(:project) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, coin_type: 'erc20')) }
    let(:award_type) { create(:award_type, project: project) }
    let(:award) { create(:award, award_type: award_type) }

    it 'with email' do
      create(:account, email: 'test2@comakery.com', ethereum_wallet: '0xaBe4449277c893B3e881c29B17FC737ff527Fa47', qtum_wallet: 'qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM')

      login issuer.account
      award.update(status: 'ready')
      post :recipient_address, format: 'js', params: {
        project_id: project.to_param,
        award_type_id: award_type.to_param,
        award_id: award.id,
        email: 'test2@comakery.com'
      }
      expect(response.status).to eq(200)
      expect(response.media_type).to eq('application/json')
      expect(JSON.parse(response.body)['address']).to eq('0xaBe4449277c893B3e881c29B17FC737ff527Fa47')

      project.token.update(coin_type: 'qrc20')
      award.update(status: 'ready')

      post :recipient_address, format: 'js', params: {
        project_id: project.to_param,
        award_type_id: award_type.to_param,
        award_id: award.to_param,
        email: 'test2@comakery.com'
      }
      expect(response.status).to eq(200)
      expect(response.media_type).to eq('application/json')
      expect(JSON.parse(response.body)['address']).to eq('qSf62RfH28cins3EyiL3BQrGmbqaJUHDfM')
    end

    it 'with channel_id and uid' do
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

      create(:account, email: 'bobjohnson@example.com', ethereum_wallet: '0xaBe4449277c893B3e881c29B17FC737ff527Fa48')
      login issuer.account
      award.update(status: 'ready')

      post :recipient_address, format: 'js', params: {
        project_id: project.to_param,
        award_type_id: award_type.to_param,
        award_id: award.to_param,
        uid: 'receiver id',
        channel_id: project.channels.first.id
      }
      expect(response.status).to eq(200)
      expect(response.media_type).to eq('application/json')
      expect(JSON.parse(response.body)['address']).to eq('0xaBe4449277c893B3e881c29B17FC737ff527Fa48')
    end
  end
end
