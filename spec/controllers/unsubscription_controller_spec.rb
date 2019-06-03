require 'rails_helper'

RSpec.describe UnsubscriptionController, type: :controller do
  describe 'GET #new' do
    before do
      allow(controller).to receive(:verify_signature).and_return(true)
    end

    context 'with valid params' do
      it 'creates new unsubscription' do
        expect do
          get :new, params: {
            email: 'test',
            signature: 'test'
          }
          expect(controller).to have_received(:verify_signature)
          expect(response.status).to eq(200)
        end.to change(Unsubscription, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'returns an errror' do
        expect do
          get :new, params: {
            email: ''
          }
          expect(controller).to have_received(:verify_signature)
          expect(response.status).to eq(422)
        end.not_to change(Unsubscription, :count)
      end
    end
  end
end
