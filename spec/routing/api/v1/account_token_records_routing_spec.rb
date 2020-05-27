require 'rails_helper'

RSpec.describe Api::V1::AccountTokenRecordsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/account_token_records').to route_to('api/v1/account_token_records#index')
    end

    it 'routes to #new' do
      expect(get: '/api/v1/account_token_records/new').to route_to('api/v1/account_token_records#new')
    end

    it 'routes to #show' do
      expect(get: '/api/v1/account_token_records/1').to route_to('api/v1/account_token_records#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/api/v1/account_token_records/1/edit').to route_to('api/v1/account_token_records#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/api/v1/account_token_records').to route_to('api/v1/account_token_records#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/api/v1/account_token_records/1').to route_to('api/v1/account_token_records#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/api/v1/account_token_records/1').to route_to('api/v1/account_token_records#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/api/v1/account_token_records/1').to route_to('api/v1/account_token_records#destroy', id: '1')
    end
  end
end
