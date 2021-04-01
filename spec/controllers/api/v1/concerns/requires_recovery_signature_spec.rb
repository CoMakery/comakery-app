shared_examples 'requires_recovery_signature' do
  shared_examples 'requires_recovery_signature' do
    describe described_class, type: :controller do
      controller(described_class) do
        def index
          head 200
        end
      end

      subject do
        get :index, params: {
          proof: {
            signature: 'dummy'
          }
        }
      end

      context 'when signature is present' do
        before do
          allow_any_instance_of(Comakery::APISignature).to receive(:verify).and_return(true)
        end

        it { is_expected.to have_http_status(:success) }

        it 'creates ApiRequestLog' do
          expect { subject }.to change(ApiRequestLog, :count).by(1)
        end

        context 'with sensitive data to be filtered' do
          subject do
            get :index, params: {
              body: {
                data: {
                  payload: 'SENSITIVE'
                }
              },
              proof: {
                signature: 'dummy'
              }
            }
          end

          it { is_expected.to have_http_status(:success) }

          it 'filters the data' do
            subject
            expect(ApiRequestLog.last.body.dig('body', 'data', 'payload')).to eq('FILTERED')
          end
        end
      end

      context 'when signature is not present' do
        before do
          allow(controller).to receive(:verify_signature).and_call_original
        end

        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end
end
