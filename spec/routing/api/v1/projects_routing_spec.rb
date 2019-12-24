require 'rails_helper'

RSpec.describe Api::V1::ProjectsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/v1/projects').to route_to('api/v1/projects#index', format: :json)
    end

    it 'routes to #show' do
      expect(get: '/api/v1/projects/1').to route_to('api/v1/projects#show', id: '1', format: :json)
    end
  end
end
