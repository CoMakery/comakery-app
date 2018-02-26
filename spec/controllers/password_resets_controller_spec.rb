require 'rails_helper'

describe PasswordResetsController do
  describe '#new' do
    it 'redirect to signup page' do
      get :new
      expect(response.status).to eq 200
    end
  end
end
