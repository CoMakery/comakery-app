require 'rails_helper'

RSpec.describe Dashboard::AccountsController, type: :controller do
  let(:project) { create(:project, visibility: :public_listed) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { project_id: project.to_param }
      expect(response).to be_successful
    end
  end
end
