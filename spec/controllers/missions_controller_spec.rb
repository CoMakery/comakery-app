require 'rails_helper'
require 'refile/file_double'

describe MissionsController do
  let(:account) { create(:account, comakery_admin: true) }
  let(:mission) { create(:mission) }

  before { login(account) }

  describe '#index' do
    render_views
    it 'renders mission index page' do
      get :index
      expect(response.status).to eq 200
      expect(response).to render_template('missions/index')
    end
  end

  describe '#new' do
    render_views
    it 'redirect to new mission page' do
      get :new
      expect(response.status).to eq 200
      expect(response).to render_template('missions/new')
    end
  end

  describe '#edit' do
    render_views
    it 'redirect to edit mission page' do
      get :edit, params: { id: mission }
      expect(response.status).to eq 200
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
