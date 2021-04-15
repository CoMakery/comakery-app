shared_examples 'protected with recaptcha' do
  describe '#recaptcha_valid?' do
    subject { controller.recaptcha_valid?(model: nil, action: nil) }

    context 'when v3 is valid' do
      before do
        allow_any_instance_of(described_class).to receive(:verify_recaptcha_v3).and_return(true)
      end

      it { is_expected.to be_truthy }
    end

    context 'when v3 is invalid' do
      before do
        allow_any_instance_of(described_class).to receive(:verify_recaptcha_v3).and_return(false)
      end

      context 'and v2 is valid' do
        before do
          allow_any_instance_of(described_class).to receive(:verify_recaptcha_v2).and_return(true)
        end

        it { is_expected.to be_truthy }
      end

      context 'and v2 is invalid' do
        before do
          allow_any_instance_of(described_class).to receive(:verify_recaptcha_v2).and_return(false)
        end

        it 'fallbacks to v2' do
          subject

          expect(assigns[:fallback_to_recaptcha_v2]).to be_truthy
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
