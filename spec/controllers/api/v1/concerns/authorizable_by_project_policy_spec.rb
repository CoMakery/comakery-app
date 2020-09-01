shared_examples 'authorizable_by_project_policy' do
  describe described_class, type: :controller do
    controller(described_class) do
      def index
        head 200
      end
    end

    let!(:project) { create(:project) }

    context 'when project is editable by account' do
      before do
        allow(controller).to receive(:project).and_return(project)
        login(project.account)
      end

      it 'sets authorization' do
        get :index
        expect(controller.authorized).to be_truthy
      end
    end

    context 'when project is not editable by account' do
      before do
        allow(controller).to receive(:project).and_return(project)
        allow(controller).to receive(:authorized).and_call_original
      end

      it 'does nothing' do
        get :index
        expect(controller.authorized).to be_falsey
      end
    end
  end
end
