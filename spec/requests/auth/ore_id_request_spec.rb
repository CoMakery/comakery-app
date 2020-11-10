require 'rails_helper'

RSpec.describe 'Auth::OreIds', type: :request do
  describe 'GET /new' do
    it 'returns http success' do
      get '/auth/ore_id/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /receive' do
    it 'returns http success' do
      get '/auth/ore_id/receive'
      expect(response).to have_http_status(:success)
    end
  end
end
