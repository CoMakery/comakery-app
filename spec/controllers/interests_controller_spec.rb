require 'rails_helper'

RSpec.describe InterestsController, type: :controller do
  let!(:account) { create(:account) }
  let!(:project) { create(:project, visibility: :public_listed) }
  let!(:specialty) { create(:specialty) }
  let(:valid_session) { {} }

  before do
    login account
  end

  describe 'POST #create' do
    context 'with valid params' do
      context 'with specialty provided' do
        it 'interests the requested project with custom specialty' do
          post :create, params: { project_id: project.id, specialty_id: specialty.id, format: :json }, session: valid_session
          project.reload

          expect(response).to be_successful
          expect(project.interested).to include(account)
          expect(project.interests.where(account: account).last.specialty).to eq(specialty)
        end
      end

      context 'without specialty provided' do
        it 'interests the requested project with accounts specialty' do
          post :create, params: { project_id: project.id, format: :json }, session: valid_session
          project.reload

          expect(response).to be_successful
          expect(project.interested).to include(account)
          expect(project.interests.where(account: account).last.specialty).to eq(account.specialty)
        end
      end
    end

    context 'with invalid params (interest already present)' do
      before do
        project.interests.create(account: account, specialty: account.specialty)
      end

      it 'returns an error' do
        post :create, params: { project_id: project.id, format: :json }, session: valid_session
        project.reload

        expect(response).not_to be_successful
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid params' do
      before do
        project.interests.create(account: account, specialty: account.specialty)
        project.interests.create(account: account, specialty: specialty)
      end

      it 'removes accounts interests for requested project' do
        delete :destroy, params: { project_id: project.id, id: 0, format: :json }, session: valid_session
        project.reload

        expect(response).to be_successful
        expect(project.interested).not_to include(account)
      end
    end
  end
end
