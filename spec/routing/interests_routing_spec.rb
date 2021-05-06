require 'rails_helper'

RSpec.describe InterestsController, type: :routing do
  describe 'routing' do
    it 'routes to #create' do
      expect(post: '/projects/1/interests').to route_to('interests#create', project_id: '1', format: :json)
    end

    it 'routes to #destroy' do
      expect(delete: '/projects/1/interests/2').to route_to('interests#destroy', project_id: '1', id: '2', format: :json)
    end
  end
end
