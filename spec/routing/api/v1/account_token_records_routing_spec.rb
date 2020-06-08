require 'rails_helper'

RSpec.describe Api::V1::AccountTokenRecordsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/projects/1/account_token_records').to route_to('api/v1/account_token_records#index', project_id: '1', format: :json)
    end

    it 'routes to #show' do
      expect(get: '/api/v1/projects/1/account_token_records/1').to route_to('api/v1/account_token_records#show', id: '1', project_id: '1', format: :json)
    end

    it 'routes to #create' do
      expect(post: '/api/v1/projects/1/account_token_records').to route_to('api/v1/account_token_records#create', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/projects/1/account_token_records/1').to route_to('api/v1/account_token_records#destroy', id: '1', project_id: '1', format: :json)
    end
  end
end
