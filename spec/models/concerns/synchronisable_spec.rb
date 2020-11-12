shared_examples 'synchronisable' do
  before { allow_any_instance_of(described_class).to receive(:sync_allowed?).and_call_original }

  it { is_expected.to have_many(:synchronisations).dependent(:destroy) }

  subject { described_class.new }
  specify { expect(subject.min_seconds_between_syncs).to eq(10) }
  specify { expect(subject.max_seconds_in_pending).to eq(60) }

  describe '#latest_synchronisation' do
    before { allow(subject).to receive(:synchronisations).and_return([Synchronisation.new]) }
    specify { expect(subject.latest_synchronisation).to be_a(Synchronisation) }
  end

  describe '#sync_allowed?' do
    context 'when next_sync_allowed_after is earlier than current time' do
      before { allow(subject).to receive(:next_sync_allowed_after).and_return(1.day.ago) }
      specify { expect(subject.sync_allowed?).to be_truthy }
    end

    context 'when next_sync_allowed_after is later than current time' do
      before { allow(subject).to receive(:next_sync_allowed_after).and_return(1.day.from_now) }
      specify { expect(subject.sync_allowed?).to be_falsey }
    end
  end

  describe '#sync_in_progress?' do
    context 'latest_synchronisation is not in progress' do
      before { allow(subject).to receive(:latest_synchronisation).and_return(Synchronisation.new(status: :ok)) }
      specify { expect(subject.sync_in_progress?).to be_falsey }
    end

    context 'latest_synchronisation is in progress' do
      context 'and its created less than max_seconds_in_pending ago' do
        before { allow(subject).to receive(:latest_synchronisation).and_return(Synchronisation.new(status: :in_progress, created_at: 1.day.from_now)) }
        specify { expect(subject.sync_in_progress?).to be_truthy }
      end

      context 'and its created more than max_seconds_in_pending ago' do
        before { allow(subject).to receive(:latest_synchronisation).and_return(Synchronisation.new(status: :in_progress, created_at: 1.day.ago)) }
        specify { expect(subject.sync_in_progress?).to be_falsey }
      end
    end
  end

  describe '#failed_transactions_row' do
    context 'when latest_transaction is failed' do
      before { allow(subject.synchronisations).to receive(:pluck).and_return(%w[ok failed failed]) }

      it 'returns number of failed transactions in row' do
        expect(subject.failed_transactions_row).to eq(2)
      end
    end

    context 'when latest_transaction is not failed' do
      before { allow(subject.synchronisations).to receive(:pluck).and_return(['ok']) }
      specify { expect(subject.failed_transactions_row).to eq(0) }
    end
  end

  describe '#next_sync_allowed_after' do
    context 'when latest_transaction is not present' do
      before { allow(subject).to receive(:latest_transaction).and_return(nil) }
      specify { expect(subject.next_sync_allowed_after).to eq(0) }
    end

    context 'when latest_transaction is in progress' do
      before do
        allow(subject).to receive(:latest_synchronisation).and_return(Synchronisation.new(status: :in_progress))
        allow(subject).to receive(:sync_in_progress?).and_return(true)
      end

      specify { expect(subject.next_sync_allowed_after).to be > Time.current }
    end

    context 'when latest_transaction was ok' do
      before { allow(subject).to receive(:latest_synchronisation).and_return(Synchronisation.new(status: :ok, updated_at: 1.day.ago)) }
      specify { expect(subject.next_sync_allowed_after).to eq(subject.latest_synchronisation.updated_at + subject.min_seconds_between_syncs) }
    end

    context 'when latest_transaction was failed' do
      before do
        allow(subject).to receive(:latest_synchronisation).and_return(Synchronisation.new(status: :failed, updated_at: 1.day.ago))
        allow(subject).to receive(:failed_transactions_row).and_return(2)
      end

      specify { expect(subject.next_sync_allowed_after).to eq(subject.latest_synchronisation.updated_at + subject.min_seconds_between_syncs**2) }
    end
  end
end
