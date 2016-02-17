require 'rails_helper'

describe LoggedOutController do
  describe 'take_action' do
    it 'should get index' do
      get :take_action
      expect(response).to be_success
    end
  end
end
