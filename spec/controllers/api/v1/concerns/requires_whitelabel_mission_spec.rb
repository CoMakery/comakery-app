shared_examples 'requires_whitelabel_mission' do
  describe described_class, type: :controller do
    controller(described_class) do
      def index
        head 200
      end
    end

    context 'when whitelabel mission is present' do
      before do
        allow(controller).to receive(:whitelabel_mission).and_return(create(:mission))
        allow(controller).to receive(:verify_signature).and_return(true)
      end

      it 'does nothing' do
        get :index
        expect(response).to be_successful
      end
    end

    context 'when whitelabel mission is not present' do
      before do
        allow(controller).to receive(:whitelabel_mission).and_return(nil)
        allow(controller).to receive(:verify_signature).and_return(true)
      end

      it 'returns an error' do
        get :index
        expect(response.status).to eq(401)
        expect(controller.instance_variable_get(:@errors)).to eq({ authentication: 'Requires whitelabel' })
        expect(response).to render_template('api/v1/error.json')
      end
    end
  end
end
