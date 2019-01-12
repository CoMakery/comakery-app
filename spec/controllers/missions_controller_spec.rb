require 'rails_helper'
require 'refile/file_double'

describe MissionsController do
  let!(:token) { create :token }
  let!(:mission1) { create :mission, name: 'test1', token_id: token.id }
  let!(:mission2) { create :mission, name: 'test1', token_id: token.id }
  let!(:admin_account) { create :account, comakery_admin: true }
  let!(:account) { create :account }

  before do
    login(admin_account)
  end

  describe '#index' do
    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in without admin flag' do
      it 'returns no mission' do
        login(account)
        get :index
        expect(response.status).to eq(200)
        expect(assigns[:missions].count).to eq(0)
      end
    end

    context 'when logged in with admin flag' do
      it 'returns correct react component' do
        get :index
        expect(response.status).to eq(200)
        expect(assigns[:missions].count).to eq(2)
      end
    end
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

  describe '#edit' do
    context 'when not logged in' do
      it 'redirects to root' do
        session[:account_id] = nil
        get :edit, params: { id: mission1.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in without admin flag' do
      it 'redirects to root' do
        login(account)
        get :edit, params: { id: mission1.id }
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in with admin flag' do
      it 'returns correct react component' do
        get :edit, params: { id: mission1.id }
        expect(response.status).to eq(200)
        expect(assigns[:mission]).to eq(mission1)
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
        put :update, params: { id: mission1, mission: { name: 'test1_name' } }
        expect(response.status).to eq(200)
      end.to change { mission1.reload.name }.from('test1').to('test1_name')
    end

    it 'renders error if param is blank' do
      expect do
        put :update, params: { id: mission1, mission: { name: '' } }
        expect(response.status).to eq(422)
      end.not_to change { mission1.name }
    end

    it 'renders error if name is too long' do
      expect do
        put :update, params: { id: mission1, mission: { name: 'a' * 101 } }
        expect(response.status).to eq(422)
      end.not_to change { mission1.name }
    end
  end

  describe '#rearrange' do
    it 'rearrange missions' do
      display_orders = [mission1.display_order, mission2.display_order]
      mission_ids = [mission1.id, mission2.id]
      expect do
        post :rearrange, params: { direction: -1, display_orders: display_orders, mission_ids: mission_ids }
        expect(response.status).to eq(200)
      end.to change { mission1.reload.display_order }.from(display_orders[0]).to(display_orders[1])
    end
  end
end
