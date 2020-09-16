require 'rails_helper'

RSpec.describe AwardTypesController, type: :controller do
  let(:issuer) { create(:authentication) }
  let(:project) { create(:project, account: issuer.account, public: false, maximum_tokens: 100_000_000, token: create(:token, _token_type: 'erc20', _blockchain: :ethereum_ropsten)) }
  let(:specialty) { create(:specialty) }

  let(:valid_attributes) do
    {
      project_id: project.to_param,
      specialty_id: specialty.to_param,
      name: 'test',
      goal: 'none',
      description: 'none'
    }
  end

  let(:invalid_attributes) do
    {
      project_id: project.to_param,
      name: 't' * 200
    }
  end

  before do
    login(issuer.account)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      AwardType.create! valid_attributes
      get :index, params: { project_id: project.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new, params: { project_id: project.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      award_type = AwardType.create! valid_attributes
      get :edit, params: { project_id: project.to_param, id: award_type.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new AwardType' do
        expect do
          post :create, params: {
            project_id: project.to_param,
            batch: valid_attributes
          }
          expect(response.status).to eq(200)
          expect(response.media_type).to eq('application/json')
          expect(JSON.parse(response.body)['message']).to eq('Batch created')
          expect(JSON.parse(response.body)['id']).to eq(project.award_types.last.id)
        end.to change(AwardType, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'returns an errror' do
        expect do
          post :create, params: {
            project_id: project.to_param,
            batch: invalid_attributes
          }
          expect(response.status).to eq(422)
          expect(response.media_type).to eq('application/json')
          expect(JSON.parse(response.body)['message']).to eq('Name is too long (maximum is 100 characters)')
        end.not_to change(AwardType, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          name: 'new name'
        }
      end

      it 'updates the requested award_type' do
        award_type = AwardType.create! valid_attributes
        post :update, params: {
          id: award_type.to_param,
          project_id: project.to_param,
          batch: new_attributes
        }
        expect(response.status).to eq(200)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)['message']).to eq('Batch updated')
        expect(JSON.parse(response.body)['id']).to eq(project.award_types.last.id)
        award_type.reload
        expect(award_type.name).to eq('new name')
      end
    end

    context 'with invalid params' do
      it 'returns an errror' do
        award_type = AwardType.create! valid_attributes
        post :update, params: {
          id: award_type.to_param,
          project_id: project.to_param,
          batch: invalid_attributes
        }
        expect(response.status).to eq(422)
        expect(response.media_type).to eq('application/json')
        expect(JSON.parse(response.body)['message']).to eq('Name is too long (maximum is 100 characters)')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested award_type' do
      award_type = AwardType.create! valid_attributes
      expect do
        delete :destroy, params: { project_id: project.to_param, id: award_type.to_param }
      end.to change(AwardType, :count).by(-1)
    end

    it 'redirects to the award_types list' do
      award_type = AwardType.create! valid_attributes
      delete :destroy, params: { project_id: project.to_param, id: award_type.to_param }
      expect(response).to redirect_to(project_award_types_url(project))
    end
  end
end
