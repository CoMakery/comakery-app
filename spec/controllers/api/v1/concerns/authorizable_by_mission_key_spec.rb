shared_examples 'authorizable_by_mission_key' do
  describe described_class, type: :controller do
    controller(described_class) do
      def index
        head 200
      end
    end

    context 'when correct mission key is present' do
      before do
        allow(controller).to receive(:mission_key).and_return('key')
        allow(controller).to receive(:request_key).and_return('key')
      end

      it 'sets authorization' do
        get :index
        expect(controller.authorized).to be_truthy
      end
    end

    context 'when correct mission key is not present' do
      before do
        allow(controller).to receive(:authorized).and_call_original
      end

      it 'does nothing' do
        get :index
        expect(controller.authorized).to be_falsey
      end
    end
  end
end
