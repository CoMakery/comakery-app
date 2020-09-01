shared_examples 'requires_an_authorization' do
  describe described_class, type: :controller do
    controller(described_class) do
      def index
        head 200
      end
    end

    let!(:project) { create(:project) }

    context 'when authorization is present' do
      before do
        allow(controller).to receive(:authorized).and_return(true)
        allow(controller).to receive(:verify_signature).and_return(true)
        allow(controller).to receive(:project).and_return(project)

        project.regenerate_api_key
      end

      it 'does nothing' do
        get :index
        expect(response).to be_successful
      end
    end

    context 'when authorization is not present' do
      before do
        allow(controller).to receive(:authorized).and_return(false)
        allow(controller).to receive(:verify_signature).and_return(true)
        allow(controller).to receive(:project).and_return(project)
      end

      it 'returns an error' do
        get :index
        expect(response.status).to eq(401)
      end
    end
  end
end
