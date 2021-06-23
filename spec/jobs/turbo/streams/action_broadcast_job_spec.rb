require 'rails_helper'

RSpec.describe Turbo::Streams::ActionBroadcastJob, type: :job do
  subject { described_class.perform_now('dummy_stream', action: 'dummy_action', target: 'dummy_target', locals: locals) }

  context 'with decoratable locals' do
    let(:project) { create(:project) }
    let(:locals) { { project: project } }

    specify do
      expect(Turbo::StreamsChannel).to receive(:broadcast_action_to)
      expect(project).to receive(:decorate).and_call_original

      subject
    end
  end

  context 'with non-decoratable locals' do
    let(:project_role) { create(:project_role) }
    let(:locals) { { project_role: project_role } }

    specify do
      expect(Turbo::StreamsChannel).to receive(:broadcast_action_to)
      expect(project_role).to receive(:decorate).and_call_original

      subject
    end
  end
end
