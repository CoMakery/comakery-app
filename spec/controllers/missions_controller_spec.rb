require 'rails_helper'
require 'refile/file_double'

describe MissionsController do
  let!(:token) { create :token }
  let!(:mission) { create :mission, token_id: token.id }
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:account) { create :account }

  before do
    login(admin_account)
  end

  describe '#new' do
    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in without admin flag' do
      it 'redirects to root' do
        login(account)
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in with admin flag' do
      it 'returns correct react component' do
        get :new
        expect(response.status).to eq(200)
        expect(assigns[:mission]).to be_a_new_record
      end
    end
  end

  describe '#create' do
    it 'creates a new mission' do
      expect do
        post :create, params: {
          mission: {
            name: 'test2',
            subtitle: 'test2',
            description: 'test2',
            token_id: token.id,
            image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
            logo: fixture_file_upload('helmet_cat.png', 'image/png', :binary)
          }
        }
        expect(response.status).to eq(200)
      end.to change { Mission.count }.by(1)
    end

    it 'renders error if param is blank' do
      expect do
        post :create, params: {
          mission: {
            subtitle: 'test2',
            description: 'test2',
            token_id: token.id,
            logo: fixture_file_upload('helmet_cat.png', 'image/png', :binary)
          }
        }
        expect(response.status).to eq(422)
      end.not_to change { Mission.count }
    end
  end

  describe '#update' do
    it 'updates a mission' do
      expect do
        put :update, params: { id: mission, mission: { name: 'test1_name' } }
        expect(response.status).to eq(200)
      end.to change { mission.reload.name }.from('test1').to('test1_name')
    end

    it 'renders error if param is blank' do
      expect do
        put :update, params: { id: mission, mission: { name: '' } }
        expect(response.status).to eq(422)
      end
    end

    it 'renders error if name is too long' do
      expect do
        put :update, params: { id: mission, mission: { name: 'a' * 101 } }
        expect(response.status).to eq(422)
      end
    end
  end
end
