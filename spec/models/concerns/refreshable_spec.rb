shared_examples 'refreshable' do
  describe 'fresh?' do
    subject { described_class.fresh? }

    context 'without synced records' do
      it { is_expected.to be_nil }
    end

    context 'with synced records' do
      context 'synced more that 10 mins ago' do
        before do
          create(described_class.to_s.underscore.to_sym, status: :synced, synced_at: 11.minutes.ago)
        end

        it { is_expected.to be_falsey }
      end

      context 'synced more less 10 mins ago' do
        before do
          create(described_class.to_s.underscore.to_sym, status: :synced, synced_at: 2.minutes.ago)
        end

        it { is_expected.to be_truthy }
      end
    end
  end
end
